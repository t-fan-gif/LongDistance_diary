import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/db/app_database.dart';
import '../../core/db/db_providers.dart';
import '../../core/domain/enums.dart'; // 追加
import '../../core/repos/target_race_repository.dart';
import '../calendar/calendar_providers.dart';
import '../day_detail/day_detail_screen.dart'; // 加筆: dayPlansProviderのため
import '../../core/services/vdot_calculator.dart'; // 加筆
import '../../core/services/load_calculator.dart'; // 加筆
import '../../core/repos/plan_repository.dart'; // 加筆: PlanInputのため
import '../plan_editor/weekly_plan_screen.dart'; // 加筆: weeklyPlansProviderのため


/// 全ターゲットレース プロバイダ
final allTargetRacesProvider = FutureProvider<List<TargetRace>>((ref) async {
  final repo = ref.watch(targetRaceRepositoryProvider);
  return repo.listAllRaces();
});

/// 未来のターゲットレース プロバイダ
final upcomingRacesProvider = FutureProvider<List<TargetRace>>((ref) async {
  final repo = ref.watch(targetRaceRepositoryProvider);
  return repo.getUpcomingRaces();
});

class TargetRaceSettingsScreen extends ConsumerStatefulWidget {
  const TargetRaceSettingsScreen({super.key});

  @override
  ConsumerState<TargetRaceSettingsScreen> createState() => _TargetRaceSettingsScreenState();
}

class _TargetRaceSettingsScreenState extends ConsumerState<TargetRaceSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final racesAsync = ref.watch(allTargetRacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ターゲットレース'),
      ),
      body: racesAsync.when(
        data: (races) {
          final mainRace = races.where((r) => r.isMain).toList();
          final subRaces = races.where((r) => !r.isMain).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(context, 'メインターゲット', '🏁'),
              if (mainRace.isEmpty)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.add_circle_outline, color: Colors.grey),
                    title: const Text('メインターゲットを追加'),
                    subtitle: const Text('重要な最高目標レースを設定'),
                    onTap: () => _showEditDialog(context, isMain: true),
                  ),
                )
              else
                ...mainRace.map((race) => _RaceCard(
                      race: race,
                      onEdit: () => _showEditDialog(context, race: race),
                      onDelete: () => _deleteRace(race),
                    )),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'サブターゲット', '🎯'),
              if (subRaces.isEmpty)
                const Card(
                  child: ListTile(
                    title: Text('サブターゲットがありません'),
                    subtitle: Text('下の「＋」ボタンで追加できます'),
                  ),
                )
              else
                ...subRaces.map((race) => _RaceCard(
                      race: race,
                      onEdit: () => _showEditDialog(context, race: race),
                      onDelete: () => _deleteRace(race),
                    )),
              const SizedBox(height: 80), // FAB用スペース
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(context, isMain: false),
        icon: const Icon(Icons.add),
        label: const Text('ターゲット追加'),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String emoji) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, {TargetRace? race, bool isMain = false}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _RaceEditDialog(race: race, isMain: race?.isMain ?? isMain),
    );

    if (result != null) {
      final repo = ref.read(targetRaceRepositoryProvider);
      if (race == null) {
        // 新規作成
        await repo.createRace(
          name: result['name'],
          date: result['date'],
          isMain: result['isMain'],
          note: result['note'],
          raceType: result['raceType'],
          distance: result['distance'],
        );
      } else {
        // 更新
        await repo.updateRace(
          id: race.id,
          name: result['name'],
          date: result['date'],
          isMain: result['isMain'],
          note: result['note'],
          raceType: result['raceType'],
          distance: result['distance'],
        );
      }
      // リフレッシュ
      ref.invalidate(allTargetRacesProvider);
      ref.invalidate(upcomingRacesProvider);
      
      // 他の画面への通知
      final date = result['date'] as DateTime;
      final monthDate = DateTime(date.year, date.month);
      ref.invalidate(monthCalendarDataProvider(monthDate));
      ref.invalidate(dayPlansProvider(date));
      ref.invalidate(weeklyPlansProvider);
    }
  }

  Future<void> _deleteRace(TargetRace race) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('レースを削除'),
        content: Text('「${race.name}」を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(targetRaceRepositoryProvider);
      await repo.deleteRace(race.id);
      ref.invalidate(allTargetRacesProvider);
      ref.invalidate(upcomingRacesProvider);
      
      final monthDate = DateTime(race.date.year, race.date.month);
      ref.invalidate(monthCalendarDataProvider(monthDate));
      ref.invalidate(dayPlansProvider(race.date));
      ref.invalidate(weeklyPlansProvider);
    }
  }
}

class _RaceCard extends StatelessWidget {
  const _RaceCard({
    required this.race,
    required this.onEdit,
    required this.onDelete,
  });

  final TargetRace race;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final raceDate = DateTime(race.date.year, race.date.month, race.date.day);
    final daysUntil = raceDate.difference(today).inDays;
    
    final isPast = daysUntil < 0;
    final isToday = daysUntil == 0;

    String countdownText;
    Color countdownColor;
    if (isPast) {
      countdownText = '${-daysUntil}日前';
      countdownColor = Colors.grey;
    } else if (isToday) {
      countdownText = '今日！';
      countdownColor = Colors.red;
    } else {
      countdownText = 'あと$daysUntil日';
      countdownColor = daysUntil <= 7 ? Colors.orange : Colors.teal;
    }

    // 種目表示
    String typeText = '';
    if (race.raceType != null) {
      if (race.raceType == PbEvent.other) {
        if (race.distance != null) {
          typeText = '${race.distance}m';
        } else {
          typeText = 'その他';
        }
      } else {
        typeText = race.raceType!.name.toUpperCase();
        // 簡単な変換マップがあればより良いが、一旦enum名で
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: race.isMain ? Colors.amber.shade100 : Colors.teal.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              race.isMain ? '🏁' : '🎯',
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          race.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('yyyy年M月d日（E）', 'ja').format(race.date)),
            if (typeText.isNotEmpty)
              Text(typeText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(
              countdownText,
              style: TextStyle(
                color: countdownColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('編集')),
            const PopupMenuItem(value: 'delete', child: Text('削除', style: TextStyle(color: Colors.red))),
          ],
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _RaceEditDialog extends ConsumerStatefulWidget {
  const _RaceEditDialog({this.race, required this.isMain});

  final TargetRace? race;
  final bool isMain;

  @override
  ConsumerState<_RaceEditDialog> createState() => _RaceEditDialogState();
}

class _RaceEditDialogState extends ConsumerState<_RaceEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _noteController;
  late final TextEditingController _distanceController;
  late DateTime _selectedDate;
  late bool _isMain;
  PbEvent? _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.race?.name ?? '');
    _noteController = TextEditingController(text: widget.race?.note ?? '');
    _distanceController = TextEditingController(text: widget.race?.distance?.toString() ?? '');
    _selectedDate = widget.race?.date ?? DateTime.now();
    _isMain = widget.isMain;
    _selectedType = widget.race?.raceType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.race == null ? 'レースを追加' : 'レースを編集'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'レース名',
                hintText: '例: 東京マラソン',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('日付'),
              subtitle: Text(DateFormat('yyyy年M月d日').format(_selectedDate)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
            ),
            const Divider(),
            // 種目選択
            DropdownButtonFormField<PbEvent>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: '種目（任意）',
                border: OutlineInputBorder(),
              ),
              items: [
                 const DropdownMenuItem(value: null, child: Text('種目を選択')),
                 ...PbEvent.values.map((e) => DropdownMenuItem(
                   value: e,
                   child: Text(e == PbEvent.other ? 'その他（距離入力）' : e.label),
                 )),
              ],
              onChanged: (val) {
                setState(() => _selectedType = val);
              },
            ),
            if (_selectedType == PbEvent.other) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _distanceController,
                decoration: const InputDecoration(
                  labelText: '距離 (m)',
                  hintText: '例: 3000',
                  border: OutlineInputBorder(),
                  suffixText: 'm',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('メインターゲット'),
              subtitle: const Text('重要な目標レースに設定'),
              value: _isMain,
              onChanged: (val) => setState(() => _isMain = val),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'メモ（任意）',
                hintText: '目標タイムなど',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('レース名を入力してください')),
              );
              return;
            }
            Navigator.pop(context, {
              'name': _nameController.text,
              'date': _selectedDate,
              'isMain': _isMain,
              'note': _noteController.text.isEmpty ? null : _noteController.text,
              'raceType': _selectedType,
              'distance': _selectedType == PbEvent.other 
                  ? int.tryParse(_distanceController.text) 
                  : null,
            });
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
