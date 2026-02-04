import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/enums.dart';
import '../../core/repos/plan_repository.dart';
import '../../core/services/service_providers.dart';
import '../calendar/calendar_providers.dart';
import '../day_detail/day_detail_screen.dart';
import '../settings/settings_screen.dart';

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
          _addNewRow(
            menuName: plan.menuName,
            distance: plan.distance,
            pace: plan.pace,
            zone: plan.zone,
            reps: plan.reps,
            note: plan.note,
            activityType: plan.activityType,
          );
        }
      } else {
        _addNewRow();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addNewRow({
    String? menuName,
    int? distance,
    int? pace,
    Zone? zone,
    int? reps,
    String? note,
    ActivityType activityType = ActivityType.running,
  }) {
    bool isKm = true;
    String distText = '';
    if (distance != null && distance > 0) {
      if (distance % 1000 == 0) {
        isKm = true;
        distText = (distance ~/ 1000).toString();
      } else {
        isKm = false;
        distText = distance.toString();
      }
    }

    final row = _PlanRowState();
    row.init(() => _onPaceFocusChange(row));
    if (menuName != null) {
      row.menuController.text = menuName;
      if (menuName == 'レスト') row.isRest = true;
    }
    row.distanceController.text = distText;
    row.isKm = isKm;
    if (reps != null) row.repsController.text = reps.toString();
    if (pace != null) row.paceController.text = _formatPace(pace);
    row.selectedZone = zone;
    if (note != null) row.noteController.text = note;
    row.activityType = activityType;

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

  void _handleUnitToggle(int index) => setState(() => _rows[index].isKm = !_rows[index].isKm);

  void _removeRow(int index) {
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  Future<void> _savePlans() async {
    // 有効な行があるかチェック（メニュー名が入力されているか、レストが選択されているか）
    final hasValidRow = _rows.any((row) => 
      row.isRest || row.menuController.text.trim().isNotEmpty
    );
    
    if (!hasValidRow) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('メニュー名を入力するか、レストを選択してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final inputs = <PlanInput>[];
      for (final row in _rows) {
        String menuName = row.menuController.text.trim();
        if (row.isRest) {
          menuName = 'レスト';
        }
        if (menuName.isEmpty) continue;

        final distVal = double.tryParse(row.distanceController.text) ?? 0;
        final distM = row.isKm ? (distVal * 1000).round() : distVal.round();
        final paceSec = _parsePace(row.paceController.text);
        final reps = int.tryParse(row.repsController.text) ?? 1;

        inputs.add(PlanInput(
          menuName: menuName,
          distance: row.isRest ? null : (distM > 0 ? distM : null),
          pace: row.isRest ? null : paceSec,
          zone: row.isRest ? null : row.selectedZone,
          reps: row.isRest ? 1 : reps,
          note: row.noteController.text.isEmpty ? null : row.noteController.text,
          activityType: row.activityType,
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
                FloatingActionButton.extended(
                  onPressed: () => _addNewRow(),
                  icon: const Icon(Icons.add),
                  label: const Text('行を追加'),
                  elevation: 0,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanRowState {
  final menuController = TextEditingController();
  final distanceController = TextEditingController();
  final repsController = TextEditingController(text: '1');
  final paceController = TextEditingController();
  final noteController = TextEditingController();

  late FocusNode paceFocusNode;
  bool isKm = true;
  Zone? selectedZone;
  ActivityType activityType = ActivityType.running;
  bool isRest = false;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
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
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('レスト', style: TextStyle(fontSize: 12)),
                Checkbox(
                  value: row.isRest,
                  onChanged: (v) {
                    row.isRest = v ?? false;
                    if (row.isRest) {
                      row.menuController.text = 'レスト';
                    } else {
                      row.menuController.text = '';
                    }
                    onChanged();
                  },
                ),
              ],
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
                  decoration: const InputDecoration(
                    labelText: '距離',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  ),
                  child: Text(
                    row.isKm ? 'km' : 'm',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: 'ペース',
                    hintText: '4:00',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    helperText: '入力後、枠外をタップでZone推定',
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
