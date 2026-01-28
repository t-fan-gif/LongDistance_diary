import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/enums.dart';
import '../calendar/calendar_providers.dart';
import '../day_detail/day_detail_screen.dart';

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

  Zone? _selectedZone;
  int _rpeValue = 5;
  RestType _restType = RestType.stop;
  SessionStatus _status = SessionStatus.done;

  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.sessionId != null;

    if (widget.initialDate != null) {
      _selectedDateTime = DateTime.parse(widget.initialDate!);
    } else {
      _selectedDateTime = DateTime.now();
    }

    if (_isEditMode) {
      _loadSession();
    } else {
      // 新規作成時、初期値があればセット
      if (widget.initialMenuName != null) _templateController.text = widget.initialMenuName!;
      
      if (widget.initialDistance != null) {
        // repsがある場合は掛け算して合計にするか、単にdistanceを入れるか
        // ユーザー要望「トータルの距離は...予測で出す」に従い、reps込みの距離を入れる
        int dist = int.tryParse(widget.initialDistance!) ?? 0;
        int reps = widget.initialReps != null ? (int.tryParse(widget.initialReps!) ?? 1) : 1;
        _distanceController.text = (dist * reps).toString();
      }
      
      if (widget.initialPace != null) {
        int pace = int.tryParse(widget.initialPace!) ?? 0;
        if (pace > 0) {
           final m = pace ~/ 60;
           final s = pace % 60;
           _paceController.text = '$m:${s.toString().padLeft(2, '0')}';
        }
      }

      if (widget.initialZone != null) {
        try {
          _selectedZone = Zone.values.firstWhere((e) => e.name == widget.initialZone);
        } catch (_) {}
      }

      // メモの組み立て
      final noteBuffer = StringBuffer();
      if (widget.initialReps != null && (int.tryParse(widget.initialReps!) ?? 1) > 1) {
        noteBuffer.write('セット数: ${widget.initialReps}\n');
      }
      if (widget.initialNote != null) {
         noteBuffer.write(widget.initialNote);
      }
      _noteController.text = noteBuffer.toString();
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
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatPaceForInput(int secPerKm) {
    final min = secPerKm ~/ 60;
    final sec = secPerKm % 60;
    return '$min${sec.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _templateController.dispose();
    _distanceController.dispose();
    _paceController.dispose();
    _durationController.dispose();
    _restDurationController.dispose();
    _noteController.dispose();
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
                  const Divider(),

                  // テンプレ入力
                  _buildSectionTitle('メニュー'),
                  TextFormField(
                    controller: _templateController,
                    decoration: const InputDecoration(
                      hintText: '例: 12km @E',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'メニューを入力してください';
                      }
                      return null;
                    },
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

                  // 距離
                  _buildSectionTitle('距離 (km)'),
                  TextFormField(
                    controller: _distanceController,
                    decoration: const InputDecoration(
                      hintText: '例: 12',
                      border: OutlineInputBorder(),
                      suffixText: 'km',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),

                  // ペース（1フィールド）
                  _buildSectionTitle('ペース'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _paceController,
                          decoration: const InputDecoration(
                            hintText: '430 → 4:30/km',
                            border: OutlineInputBorder(),
                            suffixText: '/km',
                          ),
                          keyboardType: TextInputType.number,
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
      await repo.deleteSession(widget.sessionId!);
      ref.invalidate(monthCalendarDataProvider);
      if (mounted) {
        context.pop();
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}年${dt.month}月${dt.day}日 ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
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
