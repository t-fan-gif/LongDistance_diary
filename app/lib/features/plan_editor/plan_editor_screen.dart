import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/enums.dart';
import '../../core/repos/plan_repository.dart';
import '../calendar/calendar_providers.dart';
import '../day_detail/day_detail_screen.dart';
import '../settings/settings_screen.dart';

class PlanEditorScreen extends ConsumerStatefulWidget {
  const PlanEditorScreen({super.key, required this.dateString});

  /// 編集対象の日付文字列 (yyyy-MM-dd)
  final String dateString;

  @override
  ConsumerState<PlanEditorScreen> createState() => _PlanEditorScreenState();
}

class _PlanEditorScreenState extends ConsumerState<PlanEditorScreen> {
  late DateTime _targetDate;
  bool _isLoading = false;

  // 編集中のプラン行のリスト
  final List<_PlanRowState> _rows = [];

  // 合計距離（m）
  int get _totalDistance {
    return _rows.fold(0, (sum, row) {
      // 距離が空の場合は0
      final dist = int.tryParse(row.distanceController.text) ?? 0;
      final reps = int.tryParse(row.repsController.text) ?? 1;
      // kmなら1000倍
      final distM = row.isKm ? dist * 1000 : dist;
      return sum + (distM * reps);
    });
  }

  @override
  void initState() {
    super.initState();
    _targetDate = DateTime.parse(widget.dateString);
    _loadPlans();
  }

  @override
  void dispose() {
    for (var row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(planRepositoryProvider);
      final plans = await repo.listPlansByDate(_targetDate);

      // 既存データがあれば行に変換
      if (plans.isNotEmpty) {
        for (final plan in plans) {
          _addNewRow(
            menuName: plan.menuName,
            distance: plan.distance,
            pace: plan.pace,
            zone: plan.zone,
            reps: plan.reps,
            note: plan.note,
          );
        }
      } else {
        // データがなければ空行を1つ追加
        _addNewRow();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addNewRow({
    String? menuName,
    int? distance,
    int? pace,
    Zone? zone,
    int? reps,
    String? note,
  }) {
    // 距離の表示形式調整（1000m単位ならkm表示にする、などのロジックを入れることも可能だが、
    // ここでは単純に保存された値がm単位なので、表示時にkm/m判定をするか？
    // シンプルに、入力時はデフォルトkmにしておくか、あるいは値を見て判断する。
    // 今回は、「1000の倍数ならkm、そうでなければm」として初期化してみる。
    
    bool isKm = true; // デフォルトkm
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
    if (menuName != null) row.menuController.text = menuName;
    row.distanceController.text = distText;
    row.isKm = isKm;
    if (reps != null) row.repsController.text = reps.toString();
    if (pace != null) {
        row.paceController.text = _formatPace(pace);
    }
    row.selectedZone = zone;
    if (note != null) row.noteController.text = note;

    // リスナー追加（合計距離再計算のため）
    row.distanceController.addListener(_onRowChanged);
    row.repsController.addListener(_onRowChanged);

    setState(() {
      _rows.add(row);
    });
  }

  void _onPaceFocusChange(_PlanRowState row) {
    if (row.paceFocusNode.hasFocus) {
      // Gain focus: remove :
      final val = row.paceController.text.replaceAll(':', '');
      row.paceController.text = val;
      row.paceController.selection = TextSelection.fromPosition(TextPosition(offset: val.length));
    } else {
      // Lose focus: add :
      final val = row.paceController.text;
      if (val.length >= 3 && !val.contains(':')) {
        final m = val.substring(0, val.length - 2);
        final s = val.substring(val.length - 2);
        row.paceController.text = '$m:$s';
      }
    }
  }

  String _formatPace(int paceSec) {
    final m = paceSec ~/ 60;
    final s = paceSec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _onRowChanged() {
    setState(() {}); // 再描画して合計値を更新
  }

  void _handleUnitToggle(int index) {
    setState(() {
      _rows[index].isKm = !_rows[index].isKm;
    });
  }

  void _removeRow(int index) {
    setState(() {
      _rows[index].dispose(); // リスナー解除等はdisposeで
      _rows.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalDistKm = _totalDistance / 1000.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_targetDate.month}/${_targetDate.day} の予定'),
        actions: [
          TextButton(
            onPressed: _savePlans,
            child: const Text('保存'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _rows.length,
                    separatorBuilder: (context, index) => const Divider(height: 32),
                    itemBuilder: (context, index) {
                      final row = _rows[index];
                      return _PlanRowItem(
                        key: ObjectKey(row), // 行識別のキー
                        row: row,
                        onDelete: () => _removeRow(index),
                        onUnitToggle: () => _handleUnitToggle(index),
                        onChanged: _onRowChanged,
                      );
                    },
                  ),
                ),
                // 合計表示と追加ボタンエリア
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
                        Text(
                          '合計: ${totalDistKm.toStringAsFixed(1)} km',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
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
            ),
    );
  }

  Future<void> _savePlans() async {
    // バリデーション: メニュー名が空の行は無視するか、エラーにするか
    // ここでは「空の行は保存しない」方針とするが、全ての行が空なら削除（クリア）扱い
    
    setState(() => _isLoading = true);
    try {
      final inputs = <PlanInput>[];

      for (final row in _rows) {
        final menuName = row.menuController.text.trim();
        if (menuName.isEmpty) continue; // 名前がない行はスキップ

        // 距離計算 (m)
        final distVal = int.tryParse(row.distanceController.text) ?? 0;
        final distM = row.isKm ? distVal * 1000 : distVal;
        
        // ペース (秒/km)
        int? paceSec;
        final paceText = row.paceController.text.trim();
        if (paceText.isNotEmpty) {
           final parts = paceText.split(':');
           if (parts.length == 2) {
             final m = int.tryParse(parts[0]) ?? 0;
             final s = int.tryParse(parts[1]) ?? 0;
             paceSec = m * 60 + s;
           } else if (parts.length == 1) {
             // 分だけ入力されたとみなすか？いや、m:ss形式を強制するか、例外的に分のみ対応するか
             final m = int.tryParse(parts[0]);
             if (m != null) paceSec = m * 60;
           }
        }

        final reps = int.tryParse(row.repsController.text) ?? 1;

        inputs.add(PlanInput(
          menuName: menuName,
          distance: distM > 0 ? distM : null,
          pace: paceSec,
          zone: row.selectedZone,
          reps: reps,
          note: row.noteController.text.isEmpty ? null : row.noteController.text,
        ));
      }

      final repo = ref.read(planRepositoryProvider);
      await repo.updatePlansForDate(_targetDate, inputs);

      // カレンダーキャッシュ更新
      ref.invalidate(monthCalendarDataProvider);
      
      // 日詳細のキャッシュ更新
      ref.invalidate(dayPlansProvider(_targetDate));

      if (mounted) {
        context.pop();
      }
    } finally {
      setState(() => _isLoading = false);
    }
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
  });

  final _PlanRowState row;
  final VoidCallback onDelete;
  final VoidCallback onUnitToggle;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // メニュー名
            Expanded(
              flex: 4,
              child: TextFormField(
                controller: row.menuController,
                decoration: InputDecoration(
                  labelText: 'メニュー名 (例: インターバル)',
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
            // 削除ボタン
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.close, color: Colors.grey),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // 距離入力
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: row.distanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '距離',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (_) => onChanged(),
              ),
            ),
            const SizedBox(width: 4),
            // 単位トグル
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
            // セット数 (× N)
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
         // Zone & Pace (Optional)
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
                items: Zone.values.map((z) => DropdownMenuItem(
                  value: z,
                  child: Text(z.name),
                )).toList(),
                onChanged: (v) {
                  row.selectedZone = v;
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
                   helperText: '例: 430 -> 4:30',
                 ),
               ),
             ),
          ],
        ),
      ],
    );
  }
}
