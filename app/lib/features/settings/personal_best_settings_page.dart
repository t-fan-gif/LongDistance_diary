import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../calendar/calendar_providers.dart';
import '../../core/domain/enums.dart';
import '../../core/services/vdot_calculator.dart';
import 'settings_screen.dart';

class PersonalBestSettingsPage extends ConsumerWidget {
  const PersonalBestSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pbsAsync = ref.watch(personalBestsProvider);

    return Scaffold(
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        title: const Text('自己ベスト管理'),
      ),
      body: pbsAsync.when(
        data: (pbs) {
          if (pbs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  '自己ベストを登録すると、走力(VDOT)に基づいた適切なトレーニングペースが自動算出されます。',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: pbs.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final pb = pbs[index];
              return ListTile(
                title: Text(_getEventName(pb.event)),
                subtitle: Text(_formatTime(pb.timeMs)),
                trailing: const Icon(Icons.edit),
                onTap: () => _showPbEditor(context, pb),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPbEditor(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showPbEditor(BuildContext context, PersonalBest? pb) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PbEditorSheet(existingPb: pb),
    );
  }

  String _getEventName(PbEvent event) {
    switch (event) {
      case PbEvent.m800: return '800m';
      case PbEvent.m1500: return '1500m';
      case PbEvent.m3000: return '3000m';
      case PbEvent.m3000sc: return '3000mSC';
      case PbEvent.m5000: return '5000m';
      case PbEvent.m10000: return '10000m';
      case PbEvent.half: return 'ハーフマラソン';
      case PbEvent.full: return 'フルマラソン';
      case PbEvent.w3000: return '3000m競歩';
      case PbEvent.w5000: return '5000m競歩';
      case PbEvent.w10000: return '10000m競歩';
      case PbEvent.w20km: return '20km競歩';
      case PbEvent.w35km: return '35km競歩';
      case PbEvent.w50km: return '50km競歩';
      case PbEvent.other: return 'その他'; // 追加
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
  ActivityType _activityType = ActivityType.running;
  final _minuteController = TextEditingController();
  final _secondController = TextEditingController();
  final _hourController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingPb != null) {
      _selectedEvent = widget.existingPb!.event;
      _activityType = widget.existingPb!.activityType;
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
            widget.existingPb != null ? '自己ベストを編集' : '自己ベストを追加',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // 走・歩 選択
          SegmentedButton<ActivityType>(
            segments: const [
              ButtonSegment(value: ActivityType.running, label: Text('ランニング')),
              ButtonSegment(value: ActivityType.walking, label: Text('競歩')),
            ],
            selected: {_activityType},
            onSelectionChanged: (set) {
              setState(() {
                _activityType = set.first;
                // 種目の初期値をリセット
                if (_activityType == ActivityType.walking) {
                   _selectedEvent = PbEvent.w5000;
                } else {
                   _selectedEvent = PbEvent.m5000;
                }
              });
            },
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
                .where((e) {
                  if (_activityType == ActivityType.walking) {
                    return e.name.startsWith('w');
                  } else {
                    return !e.name.startsWith('w');
                  }
                })
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
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _calcVdot,
            icon: const Icon(Icons.calculate),
            label: const Text('この記録でVDOT計算'),
          ),
        ],
      ),
    );
  }

  bool _needsHour(PbEvent event) {
    return event == PbEvent.half || event == PbEvent.full || event == PbEvent.w20km || event == PbEvent.w35km || event == PbEvent.w50km;
  }

  String _getEventName(PbEvent event) {
    switch (event) {
      case PbEvent.m800: return '800m';
      case PbEvent.m1500: return '1500m';
      case PbEvent.m3000: return '3000m';
      case PbEvent.m3000sc: return '3000mSC';
      case PbEvent.m5000: return '5000m';
      case PbEvent.m10000: return '10000m';
      case PbEvent.half: return 'ハーフ';
      case PbEvent.full: return 'フル';
      case PbEvent.w3000: return '3000m競歩';
      case PbEvent.w5000: return '5000m競歩';
      case PbEvent.w10000: return '10000m競歩';
      case PbEvent.w20km: return '20km競歩';
      case PbEvent.w35km: return '35km競歩';
      case PbEvent.w50km: return '50km競歩';
      case PbEvent.other: return 'その他'; // 追加
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
      activityType: _activityType,
    );

    ref.invalidate(personalBestsProvider);
    ref.invalidate(runningThresholdPaceProvider);
    ref.invalidate(walkingThresholdPaceProvider);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _calcVdot() {
     final hours = int.tryParse(_hourController.text) ?? 0;
     final minutes = int.tryParse(_minuteController.text) ?? 0;
     final seconds = int.tryParse(_secondController.text) ?? 0;
     final totalMs = ((hours * 3600) + (minutes * 60) + seconds) * 1000;
     if (totalMs > 0) {
        _showVdotResult(totalMs);
     }
  }

  void _showVdotResult(int timeMs) {
    final vdotCalc = ref.read(vdotCalculatorProvider);
    final dist = vdotCalc.getDistanceForEvent(_selectedEvent);
    
    final vdot = vdotCalc.calculateVdot(dist, timeMs ~/ 1000);
    final paces = vdotCalc.calculatePaces(vdot);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('VDOT: $vdot'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('この走力に基づいた推奨ペース'),
              const Divider(),
              ...paces.entries.map((e) {
                return ListTile(
                  title: Text(e.key.name),
                  trailing: Text(e.value.toString()),
                  dense: true,
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
