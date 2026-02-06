import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/app_database.dart';
import '../../core/db/db_providers.dart';
import '../../core/domain/enums.dart';
import '../../core/services/service_providers.dart';
import '../calendar/calendar_providers.dart';
import '../day_detail/day_detail_screen.dart';
import '../plan_editor/weekly_plan_screen.dart'; // weeklyPlansProviderのため
import '../settings/advanced_settings_screen.dart';
import '../settings/settings_screen.dart'; // menuPresetsProvider

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
    this.initialDuration, // 追加
    this.initialPlanId, // 追加
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
  final String? initialDuration; // 追加
  final String? initialPlanId; // 追加

  @override
  ConsumerState<SessionEditorScreen> createState() => _SessionEditorScreenState();
}

class _SessionEditorScreenState extends ConsumerState<SessionEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDateTime;
  final _templateController = TextEditingController();
  final _distanceController = TextEditingController(); // セットあたりの数値
  final _repsController = TextEditingController();
  final _paceController = TextEditingController();
  final _durationController = TextEditingController(); // 合計時間（分）
  final _restDurationController = TextEditingController();
  final _noteController = TextEditingController();
  
  PlanUnit _unit = PlanUnit.km;

  // レース詳細タイム用
  final _hourController = TextEditingController();
  final _minuteController = TextEditingController();
  final _secondController = TextEditingController();
  final _msController = TextEditingController();

  late FocusNode _paceFocusNode;
  late FocusNode _durationFocusNode;
  late FocusNode _distanceFocusNode;

  Zone? _selectedZone;
  int _rpeValue = 5;
  RestType _restType = RestType.stop;
  SessionStatus _status = SessionStatus.done;

  ActivityType _activityType = ActivityType.running;
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _isRace = false;
  String? _planId;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.sessionId != null;
    _paceFocusNode = FocusNode();
    _paceFocusNode.addListener(_onPaceFocusChange);
    _durationFocusNode = FocusNode();
    _durationFocusNode.addListener(_onDurationFocusChange);
    _distanceFocusNode = FocusNode();
    _distanceFocusNode.addListener(_onDistanceFocusChange);

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
        if (dist % 1000 == 0) {
          _unit = PlanUnit.km;
          _distanceController.text = (dist / 1000).toString();
        } else {
          _unit = PlanUnit.m;
          _distanceController.text = dist.toString();
        }
      } else if (widget.initialDuration != null) {
        final dur = int.tryParse(widget.initialDuration!) ?? 0;
        if (dur % 60 == 0) {
          _unit = PlanUnit.min;
          _distanceController.text = (dur / 60).toString();
        } else {
          _unit = PlanUnit.sec;
          _distanceController.text = dur.toString();
        }
      }

      _repsController.text = widget.initialReps ?? '';
      
      if (widget.initialPace != null) {
        final pace = int.tryParse(widget.initialPace!);
        if (pace != null) {
          _paceController.text = _formatPaceForInput(pace);
        }
      }

      // 時間の初期化
      if (widget.initialDuration != null || (widget.initialDistance != null && widget.initialPace != null)) {
        final reps = int.tryParse(widget.initialReps ?? '1') ?? 1;
        int totalSec = 0;
        if (widget.initialDuration != null) {
          totalSec = (int.tryParse(widget.initialDuration!) ?? 0) * reps;
        } else {
          final dist = int.tryParse(widget.initialDistance!) ?? 0;
          final pace = int.tryParse(widget.initialPace!) ?? 0;
          totalSec = ((dist * reps / 1000.0) * pace).round();
        }

        if (_isRace) {
            final h = totalSec ~/ 3600;
            final m = (totalSec % 3600) ~/ 60;
            final s = totalSec % 60;
            _hourController.text = h > 0 ? h.toString() : '';
            _minuteController.text = m.toString();
            _secondController.text = s.toString();
        } else {
            _durationController.text = (totalSec / 60).round().toString();
        }
      }

      // ペースに基づいたゾーンの初期推定
      if (_paceController.text.isNotEmpty) {
        _estimateZoneAction();
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
            final reps = session.reps ?? 1;
            final perDistM = session.distanceMainM! / reps;
            if (perDistM % 1000 == 0) {
              _unit = PlanUnit.km;
              _distanceController.text = (perDistM / 1000).toStringAsFixed(0);
            } else {
              _unit = PlanUnit.m;
              _distanceController.text = perDistM.toStringAsFixed(0);
            }
          }
          if (session.reps != null) {
            _repsController.text = session.reps.toString();
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

          if (_isRace && session.durationMainSec != null) {
            final totalSec = session.durationMainSec!;
            final h = totalSec ~/ 3600;
            final m = (totalSec % 3600) ~/ 60;
            final s = totalSec % 60;
            _hourController.text = h > 0 ? h.toString() : '';
            _minuteController.text = m.toString();
            _secondController.text = s.toString();
            _msController.text = ''; // 保存されていないため空欄か0
          }
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onDistanceFocusChange() {
    if (!_distanceFocusNode.hasFocus) {
       if (_isRace) {
         _calculateFromRaceTime();
       } else {
         // どちらか一方を計算。Durationが入っていればPaceを、なければ(あるいはPaceが既にあれば)Durationを？
         // ユーザーの意図によるが、ここでは両方向対応
         if (_durationController.text.isNotEmpty) {
           _calculatePaceFromDuration();
         } else if (_paceController.text.isNotEmpty) {
           _calculateDurationFromPace();
         }
       }
    }
  }

  void _onDurationFocusChange() {
    if (!_durationFocusNode.hasFocus) {
       if (!_isRace) _calculatePaceFromDuration();
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
      
      // Calculate duration if pace is entered
      if (!_isRace && _distanceController.text.isNotEmpty) {
        _calculateDurationFromPace();
      }
    }
  }

  void _calculatePaceFromDuration() {
    final val = double.tryParse(_distanceController.text) ?? 0;
    final reps = int.tryParse(_repsController.text) ?? 1;
    final durMin = double.tryParse(_durationController.text) ?? 0;
    
    if (durMin <= 0) return;

    double distKm = 0;
    if (_unit == PlanUnit.km) {
      distKm = val * reps;
    } else if (_unit == PlanUnit.m) {
      distKm = (val * reps) / 1000.0;
    } else {
      // 時間ベース（分・秒）の場合は、ここでの自力計算は難しい（距離が不明なため）
      // ただし、もし距離などの別の情報があれば計算可能だが、現状は距離ベースの時のみペースを出す
      return;
    }
    
    if (distKm > 0) {
      final totalSec = durMin * 60;
      final paceSecPerKm = (totalSec / distKm).round();
      _paceController.text = _formatPaceForInput(paceSecPerKm);
      _estimateZoneAction();
    }
  }

  void _calculateDurationFromPace() {
    final val = double.tryParse(_distanceController.text) ?? 0;
    final reps = int.tryParse(_repsController.text) ?? 1;
    final paceSec = _parsePaceInput(_paceController.text);
    
    if (_unit == PlanUnit.min || _unit == PlanUnit.sec) {
      // 時間ベースの場合は、入力値そのものが時間
      final unitFactor = (_unit == PlanUnit.min) ? 60 : 1;
      final totalSec = val * reps * unitFactor;
      _durationController.text = (totalSec / 60.0).round().toString();

      // ペースがあれば距離を逆算
      if (paceSec != null && paceSec > 0) {
        // 距離(km) = 時間(s) / ペース(s/km)
        final calculatedDistKm = totalSec / paceSec;
        // 距離は直接UIに反映しないほうが混乱が少ないかもしれないが、
        // 内部的に距離が必要なため、ここでは時間の反映のみに留める（保存時に計算される）
      }
      return;
    }

    // 距離ベースの場合
    double distKm = 0;
    if (_unit == PlanUnit.km) distKm = val * reps;
    else if (_unit == PlanUnit.m) distKm = (val * reps) / 1000.0;
    
    if (distKm > 0 && paceSec != null && paceSec > 0) {
      final totalSec = distKm * paceSec;
      final durMin = totalSec / 60.0;
      _durationController.text = durMin.round().toString(); 
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
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    _msController.dispose();
    _repsController.dispose();
    _paceFocusNode.dispose();
    _durationFocusNode.dispose();
    _distanceFocusNode.dispose();
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
                  const Divider(),

                  // メニュー名入力
                  _buildSectionTitle('メニュー名'),
                  TextFormField(
                    controller: _templateController,
                    decoration: InputDecoration(
                      hintText: '例: インターバル',
                      border: const OutlineInputBorder(),
                      suffixIcon: Consumer(
                        builder: (context, ref, child) {
                          final presetsAsync = ref.watch(menuPresetsProvider);
                          return presetsAsync.maybeWhen(
                            data: (presets) {
                              if (presets.isEmpty) return const SizedBox.shrink();
                              return PopupMenuButton<String>(
                                icon: const Icon(Icons.arrow_drop_down),
                                onSelected: (value) {
                                  _templateController.text = value;
                                },
                                itemBuilder: (context) => presets
                                    .map((p) => PopupMenuItem(
                                          value: p.name,
                                          child: Text(p.name),
                                        ))
                                    .toList(),
                              );
                            },
                            orElse: () => const SizedBox.shrink(),
                          );
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'メニューを入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // 予定（計画）がある場合の表示エリアを追加
                  if (_planId != null) ...[
                    Consumer(
                      builder: (context, ref, child) {
                        final allPlans = ref.watch(allPlansProvider).valueOrNull ?? [];
                        try {
                          final plan = allPlans.firstWhere((p) => p.id == _planId);
                          String planDetailText = '';
                          if (plan.distance != null) {
                             final dist = plan.distance!;
                             final dText = dist >= 1000 ? '${(dist/1000).toStringAsFixed(1)}km' : '${dist}m';
                             planDetailText = '$dText × ${plan.reps}';
                             if (plan.pace != null) {
                               planDetailText += ' @${_formatPace(plan.pace!)}/km';
                             }
                          } else if (plan.duration != null) {
                             final dur = plan.duration!;
                             final dText = dur >= 60 ? '${dur~/60}分' : '${dur}秒';
                             planDetailText = '$dText × ${plan.reps}';
                             if (plan.pace != null) {
                               planDetailText += ' @${_formatPace(plan.pace!)}/km';
                             }
                          }
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('予定されていた内容'),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Text(
                                  planDetailText,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                                ),
                              ),
                            ],
                          );
                        } catch (_) {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ],

                  // 実績入力：距離/時間 × セット
                  _buildSectionTitle('実績（距離/時間 × セット）'),
                  // 実績入力：距離/時間 × セット
                  _buildSectionTitle('実績（距離/時間 × セット）'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 左側：距離/時間
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _distanceController,
                              focusNode: _distanceFocusNode,
                              decoration: const InputDecoration(
                                labelText: '距離/時間',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () => _adjustDistance(-1.0),
                                  visualDensity: VisualDensity.compact,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => _adjustDistance(1.0),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // 中央：単位切り替えと×記号
                      Column(
                        children: [
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              setState(() {
                                switch (_unit) {
                                  case PlanUnit.km: _unit = PlanUnit.m; break;
                                  case PlanUnit.m: _unit = PlanUnit.min; break;
                                  case PlanUnit.min: _unit = PlanUnit.sec; break;
                                  case PlanUnit.sec: _unit = PlanUnit.km; break;
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.grey.shade100,
                              ),
                              child: Text(
                                _unit == PlanUnit.km ? 'km' : (_unit == PlanUnit.m ? 'm' : (_unit == PlanUnit.min ? '分' : '秒')),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('×', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      
                      // 右側：セット数
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _repsController,
                              decoration: const InputDecoration(
                                labelText: 'セット',
                                hintText: '1セット',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _calculateDurationFromPace(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () => _adjustReps(-1),
                                  visualDensity: VisualDensity.compact,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => _adjustReps(1),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('（1セットあたり）', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  const SizedBox(height: 16),
                  
                  // レース用：詳細タイム入力
                  if (_isRace) ...[
                    _buildSectionTitle('レースタイム (時:分:秒.ミリ秒)'),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _hourController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '時', border: OutlineInputBorder()), onChanged: (_) => _calculateFromRaceTime())),
                        const SizedBox(width: 4),
                        Expanded(child: TextFormField(controller: _minuteController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '分', border: OutlineInputBorder()), onChanged: (_) => _calculateFromRaceTime())),
                        const SizedBox(width: 4),
                        Expanded(child: TextFormField(controller: _secondController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '秒', border: OutlineInputBorder()), onChanged: (_) => _calculateFromRaceTime())),
                        const SizedBox(width: 4),
                        Expanded(child: TextFormField(controller: _msController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ms', border: OutlineInputBorder()), onChanged: (_) => _calculateFromRaceTime())),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 平均ペース
                  _buildSectionTitle('平均ペース'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _paceController,
                          focusNode: _paceFocusNode,
                          keyboardType: TextInputType.datetime,
                          readOnly: _isRace, 
                          decoration: InputDecoration(
                            labelText: 'ペース',
                            hintText: '4:00',
                            suffixText: '/km',
                            helperText: _isRace ? 'タイムと距離から自動計算' : '入力後、枠外タップでZone推定',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onChanged: (_) {
                            if (!_isRace) _estimateZoneAction();
                          },
                        ),
                      ),
                      if (!_isRace) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => _adjustPace(-1), // 1秒単位
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _adjustPace(1), // 1秒単位
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 時間（分） - レース以外で表示（場所移動）
                  if (!_isRace) ...[
                    _buildSectionTitle('時間（分）'),
                    TextFormField(
                      controller: _durationController,
                      focusNode: _durationFocusNode,
                      decoration: const InputDecoration(
                        hintText: '例: 60',
                        border: OutlineInputBorder(),
                        suffixText: '分',
                        helperText: '距離とペースから自動計算されます',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                  ],

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

                  const SizedBox(height: 16),
                  
                  // ステータス削除（デフォルトで完了扱い、または背後で管理）

                  // レスト
                  _buildSectionTitle('レスト'),
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<RestType>(
                          segments: const [
                            ButtonSegment(value: RestType.stop, label: Text('停止')),
                            ButtonSegment(value: RestType.jog, label: Text('ジョグ')),
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

  void _calculateFromRaceTime() {
    final h = int.tryParse(_hourController.text) ?? 0;
    final m = int.tryParse(_minuteController.text) ?? 0;
    final s = int.tryParse(_secondController.text) ?? 0;
    final ms = int.tryParse(_msController.text) ?? 0;

    final totalSec = h * 3600 + m * 60 + s + ms / 1000.0;
    final distKm = double.tryParse(_distanceController.text) ?? 0;

    if (totalSec > 0) {
      // 時間（分）を更新（小数点以下も含めるためdoubleで。保存時はroundされる）
      _durationController.text = (totalSec / 60.0).toStringAsFixed(2);

      if (distKm > 0) {
        final paceSecPerKm = (totalSec / distKm).round();
        _paceController.text = _formatPaceForInput(paceSecPerKm);
        _estimateZoneAction();
      }
    }
  }

  Future<void> _estimateZoneAction() async {
    final paceSec = _parsePaceInput(_paceController.text);
    if (paceSec != null) {
      final service = ref.read(trainingPaceServiceProvider);
      final zone = await service.estimateZoneFromPace(paceSec, _activityType);
      if (zone != null) {
        setState(() => _selectedZone = zone);
      }
    }
  }

  void _adjustPace(int deltaSec) {
    final current = _parsePaceInput(_paceController.text);
    if (current != null) {
      final newPace = (current + deltaSec).clamp(1, 3600); // 緩和
      _paceController.text = _formatPaceForInput(newPace);
      
      // ペースを変えたら時間を更新する
      if (!_isRace) _calculateDurationFromPace();
    }
  }

  void _adjustReps(int delta) {
    final current = int.tryParse(_repsController.text) ?? 1;
    final newVal = (current + delta).clamp(1, 999);
    _repsController.text = newVal.toString();
    _calculateDurationFromPace();
  }

  void _adjustDistance(double deltaKm) {
    final current = double.tryParse(_distanceController.text) ?? 0;
    final newVal = (current + deltaKm).clamp(0.0, 999.0);
    _distanceController.text = newVal.toStringAsFixed(newVal.truncateToDouble() == newVal ? 0 : 1);
    
    // 距離を変えたら「時間」を再計算する（ユーザーの要望：ペース固定で時間が変わるように）
    if (!_isRace) _calculateDurationFromPace();
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

      // 距離をメートルに変換 (トータル距離を計算)
      int? distanceM;
      final val = double.tryParse(_distanceController.text) ?? 0;
      final reps = int.tryParse(_repsController.text) ?? 1;
      
      // ペースを秒に変換
      final paceSecPerKm = _parsePaceInput(_paceController.text);

      if (val > 0) {
        if (_unit == PlanUnit.km) {
          distanceM = (val * reps * 1000).round();
        } else if (_unit == PlanUnit.m) {
          distanceM = (val * reps).round();
        } else if (paceSecPerKm != null && paceSecPerKm > 0) {
          // 時間ベース（分・秒）の場合はペースを使って距離を逆算
          final unitFactor = (_unit == PlanUnit.min) ? 60 : 1;
          final totalSec = val * reps * unitFactor;
          distanceM = (totalSec / paceSecPerKm * 1000).round();
        }
      }

      // 時間を秒に変換
      int? durationSec;
      if (_isRace) {
        final h = double.tryParse(_hourController.text) ?? 0;
        final m = double.tryParse(_minuteController.text) ?? 0;
        final s = double.tryParse(_secondController.text) ?? 0;
        final ms = double.tryParse(_msController.text) ?? 0;
        durationSec = (h * 3600 + m * 60 + s + ms / 1000.0).round();
      } else if (_durationController.text.isNotEmpty) {
        final durMin = double.tryParse(_durationController.text) ?? 0;
        durationSec = (durMin * 60).round();
      } else if (_unit == PlanUnit.min || _unit == PlanUnit.sec) {
        // durationが空でも単位が時間のときはこちらから算出
        final unitFactor = (_unit == PlanUnit.min) ? 60 : 1;
        durationSec = (val * reps * unitFactor).round();
      }

      // レスト時間
      int? restDurationSec;
      if (_restDurationController.text.isNotEmpty) {
        restDurationSec = (double.tryParse(_restDurationController.text) ?? 0).round();
      }

      // 負荷計算
      final loadCalc = ref.read(loadCalculatorProvider);
      final rTpace = await ref.read(runningThresholdPaceProvider.future).catchError((_) => 0) ?? 0;
      final wTpace = await ref.read(walkingThresholdPaceProvider.future).catchError((_) => 0) ?? 0;
      final tPace = _activityType == ActivityType.walking ? (wTpace > 0 ? wTpace : null) : (rTpace > 0 ? rTpace : null);
      
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
        isRace: _isRace, 
        reps: reps, 
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
          planId: _planId, // 追加
          reps: reps, // 追加
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
          planId: _planId, // 追加
          reps: reps, // 追加
        );
      }

      // カレンダーを更新（該当月）
      final monthKey = DateTime(_selectedDateTime.year, _selectedDateTime.month);
      ref.invalidate(monthCalendarDataProvider(monthKey));

      // 日詳細を更新（該当法）
      final dayKey = DateTime(_selectedDateTime.year, _selectedDateTime.month, _selectedDateTime.day);
      ref.invalidate(daySessionsProvider(dayKey));
      ref.invalidate(weeklyPlansProvider);
      ref.invalidate(allSessionsProvider); // 追加: 履歴・分析画面の即時更新のため
      
      // 前後の月も念のため更新（月跨ぎなどを考慮してシンプルに全カレンダーデータをリセットでも良いが、ProviderFamily全体を無効化できないため）
      // 一旦、現在の閲覧月が再取得されるように monthCalendarDataProvider 全体を無効にするには、
      // 閲覧中の月を知る必要があるが、ここではシンプルに今触った月のデータだけ更新する。
      // もし不整合が出るなら ref.refresh(monthCalendarDataProvider(monthKey)) を使う。

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e'), backgroundColor: Colors.red),
        );
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
      ref.invalidate(weeklyPlansProvider);
      ref.invalidate(allSessionsProvider); // 追加: 履歴・分析画面の即時更新のため
      
      if (mounted) {
        context.pop();
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}年${dt.month}月${dt.day}日';
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
