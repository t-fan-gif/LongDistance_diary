import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/services/service_providers.dart';
import '../calendar/calendar_providers.dart';
import '../day_detail/day_detail_screen.dart';
import '../settings/advanced_settings_screen.dart';

class SessionEditorScreen extends ConsumerStatefulWidget {
  const SessionEditorScreen({
    super.key,
    this.sessionId,
    this.initialDate,
    this.initialMenuName,
    this.initialDistance,
    this.initialPace,
    this.initialZone,
    this.initialReps,
    this.initialNote,
    this.initialActivityType,
    this.initialDailyMemo,
    this.initialIsRace, // 追加
  });

  final String? sessionId;
  final String? initialDate;
  // Planからの引き継ぎ用
  final String? initialMenuName;
  final String? initialDistance;
  final String? initialPace;
  final String? initialZone;
  final String? initialReps;
  final String? initialNote;
  final String? initialActivityType;
  final String? initialDailyMemo;
  final bool? initialIsRace; // 追加

  @override
  ConsumerState<SessionEditorScreen> createState() => _SessionEditorScreenState();
}

class _SessionEditorScreenState extends ConsumerState<SessionEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDateTime;
  final _templateController = TextEditingController();
  final _distanceController = TextEditingController();
  final _paceController = TextEditingController();
  final _durationController = TextEditingController();
  final _restDurationController = TextEditingController();
  final _noteController = TextEditingController();
  late FocusNode _paceFocusNode;

  Zone? _selectedZone;
  int _rpeValue = 5;
  RestType _restType = RestType.stop;
  SessionStatus _status = SessionStatus.done;

  ActivityType _activityType = ActivityType.running;
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _isRace = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.sessionId != null;
    _paceFocusNode = FocusNode();
    _paceFocusNode.addListener(_onPaceFocusChange);

    if (widget.initialDate != null) {
      _selectedDateTime = DateTime.parse(widget.initialDate!);
    } else {
      _selectedDateTime = DateTime.now();
    }

    if (_isEditMode) {
      _loadSession();
    } else {
      // 新規作成時、初期値があればセット
      if (widget.initialIsRace == true) { // 追加: Raceモード初期化
        _isRace = true;
        _templateController.text = widget.initialMenuName ?? 'レース';
      } else if (widget.initialMenuName != null) {
        _templateController.text = widget.initialMenuName!;
      }

      if (widget.initialActivityType != null) {
        try {
          _activityType = ActivityType.values.firstWhere((e) => e.name == widget.initialActivityType);
        } catch (_) {}
      }
      
      if (widget.initialDistance != null) {
        final dist = int.tryParse(widget.initialDistance!) ?? 0;
        final reps = int.tryParse(widget.initialReps ?? '1') ?? 1;
        _distanceController.text = ((dist * reps) / 1000.0).toString();
      }

      if (widget.initialPace != null) {
        final pace = int.tryParse(widget.initialPace!) ?? 0;
        _paceController.text = _formatPace(pace);

        // 時間の予測 (距離 / 1000 * ペース)
        if (widget.initialDistance != null && pace > 0) {
          final dist = int.tryParse(widget.initialDistance!) ?? 0;
          final reps = int.tryParse(widget.initialReps ?? '1') ?? 1;
          final totalSec = (dist * reps / 1000.0) * pace;
          _durationController.text = (totalSec / 60).round().toString();
        }
      }

      if (widget.initialZone != null) {
        try {
          _selectedZone = Zone.values.firstWhere((e) => e.name == widget.initialZone);
        } catch (_) {}
      }

      // 予定のメモと一日のメモを合体させて初期値にする
      final List<String> notes = [];
      if (widget.initialNote != null && widget.initialNote!.isNotEmpty) {
        notes.add(widget.initialNote!);
      }
      if (widget.initialDailyMemo != null && widget.initialDailyMemo!.isNotEmpty) {
        notes.add('【日記】${widget.initialDailyMemo!}');
      }
      if (notes.isNotEmpty) {
        _noteController.text = notes.join('\n');
      }
    }
  }

  Future<void> _loadSession() async {
    if (widget.sessionId == null) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(sessionRepositoryProvider);
      final session = await repo.getSessionById(widget.sessionId!);
      if (session != null) {
        setState(() {
          _selectedDateTime = session.startedAt;
          _templateController.text = session.templateText;
          if (session.distanceMainM != null) {
            _distanceController.text = (session.distanceMainM! / 1000).toString();
          }
          if (session.paceSecPerKm != null) {
            _paceController.text = _formatPaceForInput(session.paceSecPerKm!);
          }
          if (session.durationMainSec != null) {
            _durationController.text = (session.durationMainSec! ~/ 60).toString();
          }
          if (session.restDurationSec != null) {
            _restDurationController.text = session.restDurationSec.toString();
          }
          _noteController.text = session.note ?? '';
          _selectedZone = session.zone;
          _rpeValue = session.rpeValue ?? 5;
          _restType = session.restType ?? RestType.stop;
          _status = session.status;
          _activityType = session.activityType;
          _isRace = session.isRace;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onPaceFocusChange() {
    if (_paceFocusNode.hasFocus) {
      // Gain focus: remove : (e.g. 3:20 -> 320)
      final val = _paceController.text.replaceAll(':', '');
      _paceController.text = val;
      _paceController.selection = TextSelection.fromPosition(TextPosition(offset: val.length));
    } else {
      // Lose focus: add : (e.g. 320 -> 3:20)
      final val = _paceController.text;
      if (val.length >= 3 && !val.contains(':')) {
        final m = val.substring(0, val.length - 2);
        final s = val.substring(val.length - 2);
        _paceController.text = '$m:$s';
      }
    }
  }

  String _formatPaceForInput(int secPerKm) {
    final min = secPerKm ~/ 60;
    final sec = secPerKm % 60;
    // 初期表示やボタン操作時はコロン付きで表示（フォーカスがない状態を想定）
    return '$min:${sec.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _templateController.dispose();
    _distanceController.dispose();
    _paceController.dispose();
    _durationController.dispose();
    _restDurationController.dispose();
    _noteController.dispose();
    _paceFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '実績を編集' : '実績を入力'),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSession,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 日時選択
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('日時'),
                    subtitle: Text(_formatDateTime(_selectedDateTime)),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDateTime,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null && mounted) {
                        if (!context.mounted) return;
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                        );
                        if (pickedTime != null && mounted) {
                          setState(() {
                            _selectedDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  // 走・歩 選択
                  _buildSectionTitle('種別'),
                  SegmentedButton<ActivityType>(
                    segments: const [
                      ButtonSegment(value: ActivityType.running, label: Text('ランニング'), icon: Icon(Icons.directions_run)),
                      ButtonSegment(value: ActivityType.walking, label: Text('競歩'), icon: Icon(Icons.directions_walk)),
                    ],
                    selected: {_activityType},
                    onSelectionChanged: (selected) {
                      setState(() => _activityType = selected.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // レース結果フラグ
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('レース結果として記録'),
                    subtitle: const Text('ONにするとレース実績として集計されます'),
                    secondary: const Icon(Icons.emoji_events),
                    value: _isRace,
                    onChanged: (val) {
                      setState(() {
                        _isRace = val;
                        if (_isRace) {
                          _templateController.text = 'レース'; // デフォルトで入れる
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(),

                  // テンプレ入力
                  _buildSectionTitle('メニュー名'),
                  TextFormField(
                    controller: _templateController,
                    decoration: const InputDecoration(
                      hintText: '例: インターバル',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'メニューを入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // メニュー内容とTotal距離
                  // Planから遷移してきている場合はメニュー内容を表示し、Total距離を横に並べる
                  if (widget.initialReps != null && (int.tryParse(widget.initialReps!) ?? 1) > 1) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // メニュー内容
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                _buildSectionTitle('メニュー内容'),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                       Text('${(int.tryParse(widget.initialDistance ?? '0') ?? 0)}m × ${widget.initialReps}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                       if (widget.initialPace != null)
                                         Text('@${_formatPace(int.tryParse(widget.initialPace!) ?? 0)}/km', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Total距離
                        Expanded(
                          flex: 2,
                          child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                                _buildSectionTitle('Total距離'),
                                TextFormField(
                                  controller: _distanceController,
                                  decoration: const InputDecoration(
                                    hintText: '10',
                                    suffixText: 'km',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                             ],
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                     // Planでない場合は普通に距離入力（ここに置く）
                     Row(
                       children: [
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               _buildSectionTitle('Total距離 (km)'),
                               TextFormField(
                                 controller: _distanceController,
                                 decoration: const InputDecoration(
                                   hintText: '例: 12',
                                   suffixText: 'km',
                                   border: OutlineInputBorder(),
                                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                 ),
                                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
                               ),
                             ],
                           ),
                         ),
                       ],
                     ),
                  ],
                  const SizedBox(height: 16),
                  
                  // 平均ペース（ここに移動）
                  _buildSectionTitle('平均ペース'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _paceController,
                          focusNode: _paceFocusNode,
                          keyboardType: TextInputType.datetime,
                          decoration: const InputDecoration(
                            labelText: 'ペース',
                            hintText: '4:00',
                            suffixText: '/km',
                            helperText: '例: 430 -> 4:30',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => _adjustPace(-5),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _adjustPace(5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ステータス
                  _buildSectionTitle('ステータス'),
                  SegmentedButton<SessionStatus>(
                    segments: const [
                      ButtonSegment(
                        value: SessionStatus.done,
                        label: Text('完了'),
                        icon: Icon(Icons.check),
                      ),
                      ButtonSegment(
                        value: SessionStatus.partial,
                        label: Text('一部'),
                        icon: Icon(Icons.timelapse),
                      ),
                      ButtonSegment(
                        value: SessionStatus.aborted,
                        label: Text('中止'),
                        icon: Icon(Icons.cancel),
                      ),
                      ButtonSegment(
                        value: SessionStatus.skipped,
                        label: Text('未実施'),
                        icon: Icon(Icons.skip_next),
                      ),
                    ],
                    selected: {_status},
                    onSelectionChanged: (selected) {
                      setState(() => _status = selected.first);
                    },
                  ),
                  const SizedBox(height: 16),




                  const SizedBox(height: 16),

                  // ゾーン
                  _buildSectionTitle('ゾーン'),
                  SegmentedButton<Zone?>(
                    segments: Zone.values
                        .map((z) => ButtonSegment(
                              value: z,
                              label: Text(z.name),
                            ))
                        .toList(),
                    selected: {_selectedZone},
                    onSelectionChanged: (selected) {
                      setState(() => _selectedZone = selected.first);
                    },
                    emptySelectionAllowed: true,
                  ),
                  const SizedBox(height: 16),

                  // RPE（絵文字スライダー）
                  _buildSectionTitle('感覚的な強度 (RPE)'),
                  _RpeSlider(
                    value: _rpeValue,
                    onChanged: (value) => setState(() => _rpeValue = value),
                  ),
                  const SizedBox(height: 16),

                  // 時間（分）
                  _buildSectionTitle('時間（分）'),
                  TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      hintText: '例: 60',
                      border: OutlineInputBorder(),
                      suffixText: '分',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // レスト
                  _buildSectionTitle('レスト'),
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<RestType>(
                          segments: const [
                            ButtonSegment(
                              value: RestType.stop,
                              label: Text('停止'),
                            ),
                            ButtonSegment(
                              value: RestType.jog,
                              label: Text('ジョグ'),
                            ),
                          ],
                          selected: {_restType},
                          onSelectionChanged: (selected) {
                            setState(() => _restType = selected.first);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: _restDurationController,
                          decoration: const InputDecoration(
                            hintText: '60',
                            border: OutlineInputBorder(),
                            suffixText: '秒',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // メモ
                  _buildSectionTitle('メモ（任意）'),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: '備考があれば入力',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // 保存ボタン
                  ElevatedButton(
                    onPressed: _saveSession,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(_isEditMode ? '更新' : '保存'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }

  void _adjustPace(int deltaSec) {
    final current = _parsePaceInput(_paceController.text);
    if (current != null) {
      final newPace = (current + deltaSec).clamp(120, 900); // 2:00 - 15:00
      _paceController.text = _formatPaceForInput(newPace);
    }
  }

  int? _parsePaceInput(String input) {
    if (input.isEmpty) return null;

    // "4:30" or "430" -> 270秒
    final cleaned = input.replaceAll(':', '');
    if (cleaned.length < 2) return null;

    try {
      final min = int.parse(cleaned.substring(0, cleaned.length - 2));
      final sec = int.parse(cleaned.substring(cleaned.length - 2));
      return min * 60 + sec;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveSession() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(sessionRepositoryProvider);

      // 距離をメートルに変換
      int? distanceM;
      if (_distanceController.text.isNotEmpty) {
        distanceM = (double.parse(_distanceController.text) * 1000).round();
      }

      // ペースを秒に変換
      final paceSecPerKm = _parsePaceInput(_paceController.text);

      // 時間を秒に変換
      int? durationSec;
      if (_durationController.text.isNotEmpty) {
        durationSec = int.parse(_durationController.text) * 60;
      }

      // レスト時間
      int? restDurationSec;
      if (_restDurationController.text.isNotEmpty) {
        restDurationSec = int.parse(_restDurationController.text);
      }

      // 負荷計算
      final loadCalc = ref.read(loadCalculatorProvider);
      final rTpace = await ref.read(runningThresholdPaceProvider.future);
      final wTpace = await ref.read(walkingThresholdPaceProvider.future);
      final tPace = _activityType == ActivityType.walking ? wTpace : rTpace;
      
      // 暫定的なSessionオブジェクトを作成して負荷計算に回す
      final tempSession = Session(
        id: widget.sessionId ?? '',
        startedAt: _selectedDateTime,
        templateText: _templateController.text,
        status: _status,
        distanceMainM: distanceM,
        durationMainSec: durationSec,
        paceSecPerKm: paceSecPerKm,
        zone: _selectedZone,
        rpeValue: _rpeValue,
        restType: _restType,
        restDurationSec: restDurationSec,
        activityType: _activityType,
        isRace: _isRace, // 追加
      );
      final calculatedLoad = loadCalc.computeSessionRepresentativeLoad(
        tempSession,
        thresholdPaceSecPerKm: tPace,
        mode: ref.read(loadCalculationModeProvider),
      )?.toDouble();

      if (_isEditMode && widget.sessionId != null) {
        await repo.updateSession(
          id: widget.sessionId!,
          startedAt: _selectedDateTime,
          templateText: _templateController.text,
          status: _status,
          distanceMainM: distanceM,
          durationMainSec: durationSec,
          paceSecPerKm: paceSecPerKm,
          zone: _selectedZone,
          rpeValue: _rpeValue,
          restType: _restType,
          restDurationSec: restDurationSec,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          load: calculatedLoad,
          activityType: _activityType,
          isRace: _isRace, // 追加
        );
      } else {
        await repo.createSession(
          startedAt: _selectedDateTime,
          templateText: _templateController.text,
          status: _status,
          distanceMainM: distanceM,
          durationMainSec: durationSec,
          paceSecPerKm: paceSecPerKm,
          zone: _selectedZone,
          rpeValue: _rpeValue,
          restType: _restType,
          restDurationSec: restDurationSec,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          load: calculatedLoad,
          activityType: _activityType,
          isRace: _isRace, // 追加
        );
      }

      // カレンダーを更新（該当月）
      final monthKey = DateTime(_selectedDateTime.year, _selectedDateTime.month);
      ref.invalidate(monthCalendarDataProvider(monthKey));

      // 日詳細を更新（該当法）
      final dayKey = DateTime(_selectedDateTime.year, _selectedDateTime.month, _selectedDateTime.day);
      ref.invalidate(daySessionsProvider(dayKey));
      
      // 前後の月も念のため更新（月跨ぎなどを考慮してシンプルに全カレンダーデータをリセットでも良いが、ProviderFamily全体を無効化できないため）
      // 一旦、現在の閲覧月が再取得されるように monthCalendarDataProvider 全体を無効にするには、
      // 閲覧中の月を知る必要があるが、ここではシンプルに今触った月のデータだけ更新する。
      // もし不整合が出るなら ref.refresh(monthCalendarDataProvider(monthKey)) を使う。

      if (mounted) {
        context.pop();
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('実績を削除'),
        content: const Text('この実績を削除しますか？'),
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

    if (confirmed == true && widget.sessionId != null) {
      final repo = ref.read(sessionRepositoryProvider);
      
      // 削除前に月・日のキーを保持
      final monthKey = DateTime(_selectedDateTime.year, _selectedDateTime.month);
      final dayKey = DateTime(_selectedDateTime.year, _selectedDateTime.month, _selectedDateTime.day);
      
      await repo.deleteSession(widget.sessionId!);
      
      // 削除した月・日のデータを無効化
      ref.invalidate(monthCalendarDataProvider(monthKey));
      ref.invalidate(daySessionsProvider(dayKey));
      
      if (mounted) {
        context.pop();
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}年${dt.month}月${dt.day}日 ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatPace(int secPerKm) {
    final min = secPerKm ~/ 60;
    final sec = secPerKm % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}

/// RPE絵文字スライダー
class _RpeSlider extends StatelessWidget {
  const _RpeSlider({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  static const _emojis = ['😴', '😌', '🙂', '😊', '😐', '😤', '😰', '😫', '🥵', '💀', '☠️'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _emojis[value],
          style: const TextStyle(fontSize: 48),
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          label: value.toString(),
          onChanged: (v) => onChanged(v.round()),
        ),
        Text('RPE: $value'),
      ],
    );
  }
}
