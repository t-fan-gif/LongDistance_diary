import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../core/domain/enums.dart';
import '../../core/repos/plan_repository.dart';
import '../../core/repos/target_race_repository.dart';
import '../../core/services/service_providers.dart';
import '../calendar/calendar_providers.dart';
import '../day_detail/day_detail_screen.dart';
import '../settings/settings_screen.dart';
import 'weekly_plan_screen.dart'; // weeklyPlansProviderのため

class PlanEditorScreen extends ConsumerStatefulWidget {
  const PlanEditorScreen({super.key, required this.dateString});

  final String dateString;

  @override
  ConsumerState<PlanEditorScreen> createState() => _PlanEditorScreenState();
}

class _PlanEditorScreenState extends ConsumerState<PlanEditorScreen> {
  late PageController _pageController;
  late DateTime _baseDate;
  late DateTime _currentDate;
  static const int _initialPage = 5000;

  @override
  void initState() {
    super.initState();
    _baseDate = DateTime.parse(widget.dateString);
    _currentDate = _baseDate;
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentDate = _baseDate.add(Duration(days: index - _initialPage));
    });
  }

  String _formatDateTitle(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_formatDateTitle(_currentDate)} の予定'),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final date = _baseDate.add(Duration(days: index - _initialPage));
          return _SingleDayPlanEditor(
            key: ValueKey(date),
            date: date,
          );
        },
      ),
    );
  }
}

class _SingleDayPlanEditor extends ConsumerStatefulWidget {
  const _SingleDayPlanEditor({super.key, required this.date});
  final DateTime date;

  @override
  ConsumerState<_SingleDayPlanEditor> createState() => __SingleDayPlanEditorState();
}

class __SingleDayPlanEditorState extends ConsumerState<_SingleDayPlanEditor> {
  bool _isLoading = false;
  final List<_PlanRowState> _rows = [];
  final _dailyMemoController = TextEditingController();

  int get _totalDistance {
    return _rows.fold(0, (sum, row) {
      if (row.isRest) return sum;
      final dist = double.tryParse(row.distanceController.text) ?? 0;
      final reps = int.tryParse(row.repsController.text) ?? 1;
      final distM = row.isKm ? (dist * 1000).round() : dist.round();
      return sum + (distM * reps);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  @override
  void dispose() {
    for (var row in _rows) {
      row.dispose();
    }
    _dailyMemoController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(planRepositoryProvider);
      final plans = await repo.listPlansByDate(widget.date);
      final memo = await repo.getDailyMemo(widget.date);

      if (memo != null) {
        _dailyMemoController.text = memo.note;
      }

      if (plans.isNotEmpty) {
        for (final plan in plans) {
          // 単位の判定
          PlanUnit unit = PlanUnit.km;
          if (plan.duration != null && plan.duration! > 0) {
            // 時間指定
            if (plan.duration! % 60 == 0) {
              unit = PlanUnit.min;
            } else {
              unit = PlanUnit.sec;
            }
          } else if (plan.distance != null) {
            // 距離指定
            if (plan.distance! % 1000 == 0) {
               unit = PlanUnit.km;
            } else {
               unit = PlanUnit.m;
            }
          }

          _addNewRow(
            menuName: plan.menuName,
            distance: plan.distance,
            duration: plan.duration, // 追加
            unit: unit, // 追加
            pace: plan.pace,
            zone: plan.zone,
            reps: plan.reps,
            note: plan.note,
            activityType: plan.activityType,
            isRace: plan.isRace,
          );
        }
      } else {
        // ターゲットレースがあるか確認
        final targetRaces = await ref.read(targetRaceRepositoryProvider).getRacesByDate(widget.date);
        if (targetRaces.isNotEmpty) {
          final target = targetRaces.first;
          final vdotCalc = ref.read(vdotCalculatorProvider);
          int? distance;
          if (target.raceType != null) {
            if (target.raceType == PbEvent.other) {
              distance = target.distance;
            } else {
              distance = vdotCalc.getDistanceForEvent(target.raceType!);
            }
          }
          
          _addNewRow(
            menuName: target.name,
            distance: distance,
            // duration: Pace * Distance ? No, Plan logic usually inputs Distance for Race
            isRace: true,
            note: target.note,
          );

          final input = PlanInput(
            menuName: target.name,
            distance: distance,
            pace: null,
            isRace: true,
            note: target.note,
          );
          await repo.updatePlansForDate(widget.date, [input]);
          
          final monthDate = DateTime(widget.date.year, widget.date.month);
          ref.invalidate(monthCalendarDataProvider(monthDate));
          ref.invalidate(dayPlansProvider(widget.date));
        } else {
          _addNewRow();
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addNewRow({
    String? menuName,
    int? distance,
    int? duration, // 追加
    PlanUnit? unit, // 追加
    int? pace,
    Zone? zone,
    int? reps,
    String? note,
    ActivityType activityType = ActivityType.running,
    bool isRace = false,
  }) {
    // 単位と表示値の初期化
    PlanUnit initialUnit = unit ?? PlanUnit.km;
    String valText = '';

    if (duration != null && duration > 0) {
      // 時間指定がある場合
      if (unit == null) {
         if (duration % 60 == 0) {
           initialUnit = PlanUnit.min;
         } else {
           initialUnit = PlanUnit.sec;
         }
      }
      if (initialUnit == PlanUnit.min) {
        valText = (duration ~/ 60).toString();
      } else {
        initialUnit = PlanUnit.sec;
        valText = duration.toString();
      }
    } else if (distance != null && distance > 0) {
      if (unit == null) {
        if (distance % 1000 == 0) {
          initialUnit = PlanUnit.km;
        } else {
          initialUnit = PlanUnit.m;
        }
      }
      if (initialUnit == PlanUnit.km) {
        valText = (distance ~/ 1000).toString();
      } else {
        initialUnit = PlanUnit.m;
        valText = distance.toString();
      }
    }

    final row = _PlanRowState();
    row.init(() => _onPaceFocusChange(row));
    if (menuName != null) {
      row.menuController.text = menuName;
      if (menuName == 'レスト') row.isRest = true;
    }
    
    row.distanceController.text = valText;
    row.unit = initialUnit; // セット
    
    if (reps != null) row.repsController.text = reps.toString();
    if (pace != null) row.paceController.text = _formatPace(pace);
    row.selectedZone = zone;
    if (note != null) row.noteController.text = note;
    row.activityType = activityType;
    row.isRace = isRace;

    row.distanceController.addListener(_onRowChanged);
    row.repsController.addListener(_onRowChanged);

    setState(() {
      _rows.add(row);
    });
  }

  void _onPaceFocusChange(_PlanRowState row) {
    if (row.paceFocusNode.hasFocus) {
      final val = row.paceController.text.replaceAll(':', '');
      row.paceController.text = val;
      row.paceController.selection = TextSelection.fromPosition(TextPosition(offset: val.length));
    } else {
      final val = row.paceController.text;
      if (val.length >= 3 && !val.contains(':')) {
        final m = val.substring(0, val.length - 2);
        final s = val.substring(val.length - 2);
        row.paceController.text = '$m:$s';
      }
      // ペースからゾーンを推定
      _estimateZone(row);
    }
  }

  Future<void> _estimateZone(_PlanRowState row) async {
    final paceText = row.paceController.text;
    final paceSec = _parsePace(paceText);
    if (paceSec != null) {
      final service = ref.read(trainingPaceServiceProvider);
      final zone = await service.estimateZoneFromPace(paceSec, row.activityType);
      if (zone != null) {
        setState(() {
          row.selectedZone = zone;
        });
      }
    }
  }

  Future<void> _suggestPace(_PlanRowState row, Zone zone) async {
    final service = ref.read(trainingPaceServiceProvider);
    final paceSec = await service.getSuggestedPaceForZone(zone, row.activityType);
    if (paceSec != null) {
      setState(() {
        row.paceController.text = _formatPace(paceSec);
      });
    }
  }

  int? _parsePace(String text) {
    final clean = text.replaceAll(':', '');
    if (clean.length < 3) return null;
    try {
      final m = int.parse(clean.substring(0, clean.length - 2));
      final s = int.parse(clean.substring(clean.length - 2));
      return m * 60 + s;
    } catch (_) {
      return null;
    }
  }

  String _formatPace(int paceSec) {
    final m = paceSec ~/ 60;
    final s = paceSec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _onRowChanged() => setState(() {});

  void _handleUnitToggle(int index) {
    setState(() {
      final row = _rows[index];
      switch (row.unit) {
        case PlanUnit.km:
          row.unit = PlanUnit.m;
          // 値を変換するか、そのままにするか。ユーザー入力中は変換したほうが親切？
          // ここでは単純に単位だけ変えて、値の変換はしない（ユーザーが入力を間違えた場合に単位だけ直すことを想定）
          // しかし km -> m にするとき 10 -> 10000 になるべきか？
          // ユーザー要望「単位切り替え」が「換算」なのか「ラベル変更」なのか。
          // 多くのアプリでは、単位を変えると数値も換算されるのが一般的だが、
          // 操作ミス修正の場合は換算したくないこともある。
          // 今回は「入力ラベルの変更」として扱う（値は維持）。
          break;
        case PlanUnit.m:
          row.unit = PlanUnit.min;
          break;
        case PlanUnit.min:
          row.unit = PlanUnit.sec;
          break;
        case PlanUnit.sec:
          row.unit = PlanUnit.km;
          break;
      }
    });
  }

  void _removeRow(int index) {
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }



  Future<void> _savePlans() async {
    // バリデーション緩和: 全て空の場合は「予定なし」として保存（削除）を許可

    
    // 空でも処理を続行し、下のループでinputsが空になれば updatePlansForDate で削除扱いになる
    
    setState(() => _isLoading = true);
    try {
      final inputs = <PlanInput>[];
      for (final row in _rows) {
        String menuName = row.menuController.text.trim();
        if (row.isRest) {
          menuName = 'レスト';
        }
        // メニュー名がない行はスキップ
        if (menuName.isEmpty) continue;

        final val = double.tryParse(row.distanceController.text) ?? 0;
        int? distM;
        int? durationSec;

        if (row.isRest) {
           distM = null;
           durationSec = null;
        } else {
           switch (row.unit) {
             case PlanUnit.km:
               distM = (val * 1000).round();
               break;
             case PlanUnit.m:
               distM = val.round();
               break;
             case PlanUnit.min:
               durationSec = (val * 60).round();
               break;
             case PlanUnit.sec:
               durationSec = val.round();
               break;
           }
        }
        
        final paceSec = _parsePace(row.paceController.text);
        final repsStr = row.repsController.text.trim();
        final reps = repsStr.isEmpty ? 1 : (int.tryParse(repsStr) ?? 1);

        inputs.add(PlanInput(
          menuName: menuName,
          distance: distM,
          duration: durationSec,
          pace: row.isRest ? null : paceSec,
          zone: row.isRest ? null : row.selectedZone,
          reps: row.isRest ? 1 : reps,
          note: row.noteController.text.isEmpty ? null : row.noteController.text,
          activityType: row.activityType,
          isRace: row.isRace,
        ));
      }

      final repo = ref.read(planRepositoryProvider);
      await repo.updatePlansForDate(widget.date, inputs);
      await repo.updateDailyMemo(widget.date, _dailyMemoController.text.trim());

      // レストが含まれている場合は自動で実績（Session）を作成
      final hasRest = _rows.any((row) => row.isRest);
      if (hasRest) {
        final sessionRepo = ref.read(sessionRepositoryProvider);
        // 既存のレストセッションがあるかチェック
        final existingSessions = await sessionRepo.listSessionsByDate(widget.date);
        final hasRestSession = existingSessions.any((s) => s.templateText == 'レスト');
        
        if (!hasRestSession) {
          await sessionRepo.createSession(
            startedAt: widget.date,
            templateText: 'レスト',
            status: SessionStatus.done,
            distanceMainM: 0,
            rpeValue: 0,
            note: 'レスト（自動作成）',
          );
        }
      }

      final monthDate = DateTime(widget.date.year, widget.date.month);
      ref.invalidate(monthCalendarDataProvider(monthDate));
      ref.invalidate(dayPlansProvider(widget.date));
      ref.invalidate(daySessionsProvider(widget.date));
      ref.invalidate(weeklyPlansProvider);
      
      // 保存成功時のフィードバック
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('予定を保存しました'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalDistKm = _totalDistance / 1000.0;

    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ..._rows.asMap().entries.map((entry) {
                      final index = entry.key;
                      final row = entry.value;
                      return Column(
                        children: [
                          _PlanRowItem(
                            key: ObjectKey(row),
                            row: row,
                            onDelete: () => _removeRow(index),
                            onUnitToggle: () => _handleUnitToggle(index),
                            onChanged: _onRowChanged,
                            onZoneChanged: (zone) {
                              if (zone != null) _suggestPace(row, zone);
                            },
                          ),
                          const Divider(height: 32),
                        ],
                      );
                    }),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _dailyMemoController,
                      decoration: const InputDecoration(
                        labelText: '一日のメモ',
                        hintText: '今日のコンディションや全体的な注意点など',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 80), // 下部のFABと被らないように
                  ],
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '合計: ${totalDistKm.toStringAsFixed(1)} km',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    ElevatedButton.icon(
                      onPressed: _savePlans,
                      icon: const Icon(Icons.save),
                      label: const Text('この日の予定を保存'),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.extended(
                      onPressed: () => _addNewRow(),
                      icon: const Icon(Icons.add),
                      label: const Text('行を追加'),
                      elevation: 0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// 単位列挙型は core/domain/enums.dart に移動しました

class _PlanRowState {
  final menuController = TextEditingController();
  final distanceController = TextEditingController(); // 数量（距離または時間）
  final repsController = TextEditingController(); // 初期値を空に変更
  final paceController = TextEditingController();
  final noteController = TextEditingController();

  late FocusNode paceFocusNode;
  PlanUnit unit = PlanUnit.km; // 単位
  Zone? selectedZone;
  ActivityType activityType = ActivityType.running;
  bool isRest = false;
  bool isRace = false;

  bool get isKm => unit == PlanUnit.km;

  void init(VoidCallback onPaceFocusChange) {
    paceFocusNode = FocusNode();
    paceFocusNode.addListener(onPaceFocusChange);
  }

  void dispose() {
    menuController.dispose();
    distanceController.dispose();
    repsController.dispose();
    paceController.dispose();
    noteController.dispose();
    paceFocusNode.dispose();
  }
}

class _PlanRowItem extends StatelessWidget {
  const _PlanRowItem({
    super.key,
    required this.row,
    required this.onDelete,
    required this.onUnitToggle,
    required this.onChanged,
    required this.onZoneChanged,
  });

  final _PlanRowState row;
  final VoidCallback onDelete;
  final VoidCallback onUnitToggle;
  final VoidCallback onChanged;
  final ValueChanged<Zone?> onZoneChanged;

  @override
  Widget build(BuildContext context) {
    // 単位表示テキスト
    String unitLabel = 'km';
    switch (row.unit) {
      case PlanUnit.km:
        unitLabel = 'km';
        break;
      case PlanUnit.m:
        unitLabel = 'm';
        break;
      case PlanUnit.min:
        unitLabel = '分';
        break;
      case PlanUnit.sec:
        unitLabel = '秒';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 6,
              child: TextFormField(
                controller: row.menuController,
                enabled: !row.isRest,
                decoration: InputDecoration(
                  labelText: 'メニュー名',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  suffixIcon: Consumer(
                    builder: (context, ref, child) {
                      final presetsAsync = ref.watch(menuPresetsProvider);
                      return presetsAsync.maybeWhen(
                        data: (presets) => presets.isEmpty
                            ? const SizedBox.shrink()
                            : PopupMenuButton<String>(
                                icon: const Icon(Icons.arrow_drop_down),
                                onSelected: (value) {
                                  row.menuController.text = value;
                                  onChanged();
                                },
                                itemBuilder: (context) => presets
                                    .map((p) => PopupMenuItem(
                                          value: p.name,
                                          child: Text(p.name),
                                        ))
                                    .toList(),
                              ),
                        orElse: () => const SizedBox.shrink(),
                      );
                    },
                  ),
                ),
                onChanged: (_) => onChanged(),
              ),
            ),
            const Spacer(),
            if (!row.isRace)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('レスト', style: TextStyle(fontSize: 12)),
                  Checkbox(
                    value: row.isRest,
                    visualDensity: VisualDensity.compact,
                    onChanged: (v) {
                      row.isRest = v ?? false;
                      if (row.isRest) {
                        row.menuController.text = 'レスト';
                        row.isRace = false;
                      } else {
                        row.menuController.text = '';
                      }
                      onChanged();
                    },
                  ),
                ],
              ),
            if (row.isRace)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('レース', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
              ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        if (!row.isRest) ...[
          const SizedBox(height: 8),
          SegmentedButton<ActivityType>(
            segments: const [
              ButtonSegment(value: ActivityType.running, label: Text('ランニング'), icon: Icon(Icons.directions_run)),
              ButtonSegment(value: ActivityType.walking, label: Text('競歩'), icon: Icon(Icons.directions_walk)),
            ],
            selected: {row.activityType},
            onSelectionChanged: (selected) {
              row.activityType = selected.first;
              onChanged();
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: row.distanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: '距離/時間',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: onUnitToggle,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.shade100,
                  ),
                  child: SizedBox(
                    width: 32,
                    child: Text(
                      unitLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('×', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: row.repsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'セット',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Zone>(
                  value: row.selectedZone,
                  decoration: const InputDecoration(
                    labelText: 'Zone',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: Zone.values
                      .map((z) => DropdownMenuItem(
                            value: z,
                            child: Text(z.name),
                          ))
                      .toList(),
                  onChanged: (v) {
                    row.selectedZone = v;
                    onZoneChanged(v);
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: row.paceController,
                  focusNode: row.paceFocusNode,
                  keyboardType: TextInputType.number, // datetimeからnumberに変更
                  decoration: InputDecoration(
                    labelText: row.isRace ? '目標ペース (任意)' : 'ペース',
                    hintText: '4:00',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    helperText: row.isRace ? '実績から自動計算' : '入力後、枠外タップでZone推定',
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        TextFormField(
          controller: row.noteController,
          decoration: const InputDecoration(
            labelText: '個別メモ (任意)',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }
}
