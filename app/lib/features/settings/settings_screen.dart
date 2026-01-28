import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/db_providers.dart';
import '../../core/domain/enums.dart';
import '../../core/repos/personal_best_repository.dart';
import 'export_usecase.dart';

/// PersonalBestRepositoryのプロバイダ
final personalBestRepositoryProvider = Provider<PersonalBestRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PersonalBestRepository(db);
});

/// 全PBを取得
final personalBestsProvider = FutureProvider<List<PersonalBest>>((ref) async {
  final repo = ref.watch(personalBestRepositoryProvider);
  return repo.listPersonalBests();
});


// ... (existing imports)

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final pbsAsync = ref.watch(personalBestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              // PBセクション (既存コードと同じだがStateful化に伴いコピーが必要か、あるいは修正範囲を限定するか)
              // ここでは構造が変わるため、PBセクションの内容を再記述する必要があるが、
              // replace_file_contentの範囲をうまく調整する。
              // ...
              // リストの先頭部分は既存のまま生かしたいが、class定義が変わるので全体を置き換えたほうが安全。
              // しかしreplace_file_contentの制限上、既存コードとの差分だけ適用したい。
              
              // 実際にはConsumerWidget -> ConsumerStatefulWidgetへの変更は大きな変更になる。
              // ここでは一旦、既存のStatelessWidgetのまま、ConsumerWidget内で非同期処理をハンドリングする方法をとるか、
              // 完全に書き換えるか。
              // ローディング状態を持ちたいのでStatefulWidgetにするのが素直。
              // 今回はToolの制限内でやるため、全書き換えに近いアプローチをとる。
              
              // PBセクション
              ListTile(
                title: Text(
                  'パーソナルベスト',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                trailing: TextButton.icon(
                  onPressed: () => _showPbEditor(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('追加'),
                ),
              ),
              pbsAsync.when(
                data: (pbs) {
                  if (pbs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('PBを登録すると、ペース帯の推定に使用されます'),
                    );
                  }
                  return Column(
                    children: pbs
                        .map((pb) => _PbTile(
                              pb: pb,
                              onEdit: () => _showPbEditor(context, ref, pb: pb),
                            ))
                        .toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('エラー: $e'),
              ),
              const Divider(),

              // エクスポート
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('データをエクスポート'),
                subtitle: const Text('JSON形式でバックアップ'),
                onTap: _isExporting ? null : () => _handleExport(context, ref),
                trailing: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),

              // アプリ情報
              const Divider(),
              const ListTile(
                leading: Icon(Icons.info),
                title: Text('Long Distance Diary'),
                subtitle: Text('Version 1.0.0'),
              ),
            ],
          ),
          if (_isExporting)
            const ModalBarrier(dismissible: false, color: Colors.black12),
        ],
      ),
    );
  }

  Future<void> _handleExport(BuildContext context, WidgetRef ref) async {
    setState(() => _isExporting = true);
    try {
      final useCase = ref.read(exportUseCaseProvider);
      await useCase.execute();
    } catch (e) {
      if (mounted) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エクスポートに失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showPbEditor(BuildContext context, WidgetRef ref, {PersonalBest? pb}) {
// ...
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PbEditorSheet(existingPb: pb),
    );
  }
}

class _PbTile extends StatelessWidget {
  const _PbTile({required this.pb, required this.onEdit});

  final PersonalBest pb;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_getEventName(pb.event)),
      subtitle: Text(_formatTime(pb.timeMs)),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: onEdit,
      ),
    );
  }

  String _getEventName(PbEvent event) {
    switch (event) {
      case PbEvent.m800:
        return '800m';
      case PbEvent.m1500:
        return '1500m';
      case PbEvent.m3000:
        return '3000m';
      case PbEvent.m3000sc:
        return '3000mSC';
      case PbEvent.m5000:
        return '5000m';
      case PbEvent.m10000:
        return '10000m';
      case PbEvent.half:
        return 'ハーフ';
      case PbEvent.full:
        return 'フル';
    }
  }

  String _formatTime(int ms) {
    final totalSeconds = ms ~/ 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _PbEditorSheet extends ConsumerStatefulWidget {
  const _PbEditorSheet({this.existingPb});

  final PersonalBest? existingPb;

  @override
  ConsumerState<_PbEditorSheet> createState() => _PbEditorSheetState();
}

class _PbEditorSheetState extends ConsumerState<_PbEditorSheet> {
  PbEvent _selectedEvent = PbEvent.m5000;
  final _minuteController = TextEditingController();
  final _secondController = TextEditingController();
  final _hourController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingPb != null) {
      _selectedEvent = widget.existingPb!.event;
      final totalSeconds = widget.existingPb!.timeMs ~/ 1000;
      final hours = totalSeconds ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      final seconds = totalSeconds % 60;
      _hourController.text = hours > 0 ? hours.toString() : '';
      _minuteController.text = minutes.toString();
      _secondController.text = seconds.toString().padLeft(2, '0');
    }
  }

  @override
  void dispose() {
    _minuteController.dispose();
    _secondController.dispose();
    _hourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existingPb != null ? 'PBを編集' : 'PBを追加',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // 種目選択
          DropdownButtonFormField<PbEvent>(
            value: _selectedEvent,
            decoration: const InputDecoration(
              labelText: '種目',
              border: OutlineInputBorder(),
            ),
            items: PbEvent.values
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(_getEventName(e)),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedEvent = value);
            },
          ),
          const SizedBox(height: 16),

          // 記録入力
          Row(
            children: [
              if (_needsHour(_selectedEvent)) ...[
                Expanded(
                  child: TextFormField(
                    controller: _hourController,
                    decoration: const InputDecoration(
                      labelText: '時',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: TextFormField(
                  controller: _minuteController,
                  decoration: const InputDecoration(
                    labelText: '分',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _secondController,
                  decoration: const InputDecoration(
                    labelText: '秒',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _savePb,
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  bool _needsHour(PbEvent event) {
    return event == PbEvent.half || event == PbEvent.full;
  }

  String _getEventName(PbEvent event) {
    switch (event) {
      case PbEvent.m800:
        return '800m';
      case PbEvent.m1500:
        return '1500m';
      case PbEvent.m3000:
        return '3000m';
      case PbEvent.m3000sc:
        return '3000mSC';
      case PbEvent.m5000:
        return '5000m';
      case PbEvent.m10000:
        return '10000m';
      case PbEvent.half:
        return 'ハーフ';
      case PbEvent.full:
        return 'フル';
    }
  }

  Future<void> _savePb() async {
    final hours = int.tryParse(_hourController.text) ?? 0;
    final minutes = int.tryParse(_minuteController.text) ?? 0;
    final seconds = int.tryParse(_secondController.text) ?? 0;

    final totalMs = ((hours * 3600) + (minutes * 60) + seconds) * 1000;

    if (totalMs <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('有効な記録を入力してください')),
      );
      return;
    }

    final repo = ref.read(personalBestRepositoryProvider);
    await repo.upsertPersonalBest(
      event: _selectedEvent,
      timeMs: totalMs,
    );

    ref.invalidate(personalBestsProvider);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
