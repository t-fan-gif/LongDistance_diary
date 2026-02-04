import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'calendar_providers.dart';
import '../day_detail/day_detail_screen.dart';
import '../../core/domain/enums.dart';
import '../../core/db/app_database.dart';
import '../plan_editor/weekly_plan_screen.dart';
import '../settings/advanced_settings_screen.dart';
import '../settings/target_race_settings_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  final GlobalKey<WeeklyPlanScreenState> _weeklyPlanKey = GlobalKey<WeeklyPlanScreenState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final calendarDataAsync = ref.watch(monthCalendarDataProvider(selectedMonth));

    return Scaffold(
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFE64A19),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/bar.png',
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Drawerアイコンなどを白に
        toolbarHeight: 80, // 少し高さを広げて余白を確保
        title: const Padding(
          padding: EdgeInsets.only(top: 24), // 上部に余白を追加
          child: Text(
            'Long Distance Diary',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.black.withOpacity(0.2), // タブバーの背景を少し暗くして視認性向上
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              onTap: (index) {
                // リストタブがタップされたら(切り替え時も)即座にジャンプを実行
                if (index == 1) {
                  // 少し遅延させることでタブ遷移と競合しないようにする
                  Future.delayed(const Duration(milliseconds: 100), () {
                    _weeklyPlanKey.currentState?.scrollToToday(animate: false);
                  });
                }
              },
              tabs: const [
                Tab(text: '今日', icon: Icon(Icons.today, size: 18)),
                Tab(text: 'リスト', icon: Icon(Icons.view_list, size: 18)),
                Tab(text: 'カレンダー', icon: Icon(Icons.calendar_month, size: 18)),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerHeader(context),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('トレーニング履歴'),
                onTap: () async {
                  Navigator.pop(context); // ドロワーを閉じる
                  // 閉じアニメーションを少し待ってから遷移することで、戻り時の不具合を防止
                  await Future.delayed(const Duration(milliseconds: 250));
                  if (context.mounted) {
                    context.push('/history');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.analytics),
                title: const Text('トレーニング分析'),
                onTap: () async {
                  Navigator.pop(context);
                  await Future.delayed(const Duration(milliseconds: 250));
                  if (context.mounted) {
                    context.push('/analysis');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('自己ベスト入力'),
                onTap: () async {
                  Navigator.pop(context);
                  await Future.delayed(const Duration(milliseconds: 250));
                  if (context.mounted) {
                    context.push('/settings/pb');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('ターゲットレース'),
                onTap: () async {
                  Navigator.pop(context);
                  await Future.delayed(const Duration(milliseconds: 250));
                  if (context.mounted) {
                    context.push('/settings/target-race');
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('トレーニング計画サポート'),
                subtitle: const Text('ゾーン・VDOT・負荷について'),
                onTap: () async {
                  Navigator.pop(context);
                  await Future.delayed(const Duration(milliseconds: 250));
                  if (context.mounted) {
                    context.push('/training-support');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('設定'),
                onTap: () async {
                  Navigator.pop(context);
                  await Future.delayed(const Duration(milliseconds: 250));
                  if (context.mounted) {
                    context.push('/settings');
                  }
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // 今日の予定タブ
            const _TodayView(),
            // リストタブ
            WeeklyPlanScreen(
              key: _weeklyPlanKey,
              tabController: _tabController,
            ),
            // カレンダータブ
            Column(
              children: [
                // 月選択ヘッダー (重複表示を避けるため年号は削除)
                _MonthHeader(
                  selectedMonth: selectedMonth,
                  onPreviousMonth: () {
                    ref.read(selectedMonthProvider.notifier).state = DateTime(
                      selectedMonth.year,
                      selectedMonth.month - 1,
                    );
                  },
                  onNextMonth: () {
                    ref.read(selectedMonthProvider.notifier).state = DateTime(
                      selectedMonth.year,
                      selectedMonth.month + 1,
                    );
                  },
                ),
                // 曜日ヘッダー
                const _WeekdayHeader(),
                // カレンダーグリッド
                Expanded(
                  child: calendarDataAsync.when(
                    data: (days) => _CalendarGrid(days: days),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('エラー: $e')),
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.teal,
        image: DecorationImage(
          image: AssetImage('assets/drawer_bg.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history, color: Colors.white, size: 32), // フィットネスアイコンを履歴アイコンに変更案、または削除
          ),
          const SizedBox(height: 16),
          const Text(
            'LONG DISTANCE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const Text(
            'Training Diary',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.selectedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final DateTime selectedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPreviousMonth,
          ),
          const SizedBox(width: 16),
          Text(
            DateFormat('yyyy年MM月').format(selectedMonth),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNextMonth,
          ),
        ],
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey.shade100,
      child: Row(
        children: weekdays
            .map((w) => Expanded(
                  child: Center(
                    child: Text(
                      w,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({required this.days});

  final List<DayCalendarData> days;

  @override
  Widget build(BuildContext context) {
    // 初日の曜日を計算してオフセットを調整
    final firstDate = days.first.date;
    final offset = (firstDate.weekday - 1); 

    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.6, // 少し縦長にする
      ),
      itemCount: days.length + offset,
      itemBuilder: (context, index) {
        if (index < offset) {
          return const SizedBox.shrink();
        }
        final dayData = days[index - offset];
        return _CalendarCell(dayData: dayData);
      },
    );
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({required this.dayData});

  final DayCalendarData dayData;

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(dayData.date);
    
    return InkWell(
      onTap: () {
        context.push('/day/${dayData.date.toIso8601String().split('T')[0]}');
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _getHeatmapColor(dayData.heatmapBucket),
          border: Border.all(
            color: isToday ? Colors.teal : Colors.grey.shade300,
            width: isToday ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            // レースデイマーカー
            Consumer(
              builder: (context, ref, child) {
                final racesAsync = ref.watch(allTargetRacesProvider);
                final planRace = dayData.plans.where((p) => p.isRace).firstOrNull;

                return racesAsync.maybeWhen(
                  data: (races) {
                    final target = races.where((r) => 
                      r.date.year == dayData.date.year && 
                      r.date.month == dayData.date.month && 
                      r.date.day == dayData.date.day
                    ).firstOrNull;

                    if (target == null && planRace == null) return const SizedBox.shrink();

                    final displayName = target?.name ?? planRace!.menuName;
                    final isMain = target?.isMain ?? false;
                    final isPlanRace = target == null && planRace != null;
                    
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                      decoration: BoxDecoration(
                        color: isMain ? Colors.orange : (isPlanRace ? Colors.orange.shade300 : Colors.teal.shade300),
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0)),
                      ),
                      child: Text(
                        displayName,
                        style: const TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                );
              },
            ),
            // 日付
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2),
              color: isToday ? Colors.teal : Colors.black12,
              child: Text(
                dayData.date.day.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isToday ? Colors.white : Colors.black87,
                ),
              ),
            ),
            
            // 内容表示
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: dayData.maxLoadSession != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayData.maxLoadSession!.templateText,
                            style: const TextStyle(fontSize: 8, overflow: TextOverflow.ellipsis),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                          if (dayData.dayLoad > 0)
                            Text(
                              'L:${dayData.dayLoad}',
                              style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                            ),
                          if (dayData.totalDistanceM > 0)
                            Text(
                              '${(dayData.totalDistanceM / 1000).toStringAsFixed(1)}k',
                              style: const TextStyle(fontSize: 7, color: Colors.black54),
                            ),
                        ],
                      )
                    : Consumer(
                        builder: (context, ref, child) {
                          final racesAsync = ref.watch(allTargetRacesProvider);
                          final hasRace = racesAsync.maybeWhen(
                            data: (races) => races.any((r) =>
                              r.date.year == dayData.date.year &&
                              r.date.month == dayData.date.month &&
                              r.date.day == dayData.date.day
                            ),
                            orElse: () => false,
                          );
                          if (dayData.plans.isNotEmpty || hasRace) {
                            return const Center(
                              child: Icon(Icons.event_note, size: 12, color: Colors.orange),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHeatmapColor(int bucket) {
    switch (bucket) {
      case 0: return Colors.transparent;
      case 1: return Colors.teal.shade50;
      case 2: return Colors.teal.shade100;
      case 3: return Colors.teal.shade200;
      case 4: return Colors.teal.shade300;
      case 5: return Colors.teal.shade400;
      default: return Colors.transparent;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _TodayView extends ConsumerWidget {
  const _TodayView();

  static const _emojis = ['😴', '😌', '🙂', '😊', '😐', '😤', '😰', '😫', '🥵', '💀', '☠️'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final dateKey = DateTime(today.year, today.month, today.day);
    
    final sessionsAsync = ref.watch(daySessionsProvider(dateKey));
    final plansAsync = ref.watch(dayPlansProvider(dateKey));
    final rTpace = ref.watch(runningThresholdPaceProvider).valueOrNull;
    final wTpace = ref.watch(walkingThresholdPaceProvider).valueOrNull;
    final loadCalc = ref.watch(loadCalculatorProvider);
    final loadMode = ref.watch(loadCalculationModeProvider);
    final racesAsync = ref.watch(upcomingRacesProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ターゲットレース・カウントダウン
        racesAsync.when(
          data: (races) {
            if (races.isEmpty) return const SizedBox.shrink();
            
            final mainRace = races.where((r) => r.isMain).toList();
            final nearestSub = races.where((r) => !r.isMain).toList();
            
            final List<Widget> widgets = [];
            
            if (mainRace.isNotEmpty) {
              for (final race in mainRace) {
                final diff = DateTime(race.date.year, race.date.month, race.date.day).difference(dateKey).inDays;
                if (diff >= 0) {
                  widgets.add(_buildRaceCountdown(context, 'メインターゲット', race.name, diff, isMain: true));
                }
              }
            }
            
            if (nearestSub.isNotEmpty) {
              final race = nearestSub.first;
              final diff = DateTime(race.date.year, race.date.month, race.date.day).difference(dateKey).inDays;
              if (diff >= 0) {
                widgets.add(_buildRaceCountdown(context, 'サブターゲット', race.name, diff, isMain: false));
              }
            }
            
            if (widgets.isEmpty) return const SizedBox.shrink();
            
            return Column(children: [
              ...widgets,
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
            ]);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        _buildSectionHeader(context, '今日の予定 (${DateFormat('M月d日').format(dateKey)})'),
        
        // レースと予定を統合して表示
        Consumer(
          builder: (context, ref, child) {
            final plansAsync = ref.watch(dayPlansProvider(dateKey));
            final racesAsync = ref.watch(allTargetRacesProvider);

            return racesAsync.when(
              data: (races) {
                final race = races.isEmpty ? null : races.where(
                  (r) => r.date.year == dateKey.year && r.date.month == dateKey.month && r.date.day == dateKey.day
                ).firstOrNull;

                return plansAsync.when(
                  data: (plans) {
                    final List<Widget> items = [];

                    // 1. レースがあれば最初に出す
                    if (race != null) {
                      items.add(Card(
                        color: Colors.orange.shade100,
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Text('🏁', style: TextStyle(fontSize: 28)),
                          title: Text(race.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          subtitle: Text(
                            race.raceType != null 
                              ? '本日開催: ${race.raceType == PbEvent.other && race.distance != null ? '${race.distance}m' : race.raceType!.label}'
                              : '本日開催: レース',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.directions_run, size: 32, color: Colors.orange),
                            tooltip: 'レース結果を入力',
                            onPressed: () {
                              // 競歩種目かどうかを判定
                              final isWalking = race.raceType != null && 
                                [PbEvent.w3000, PbEvent.w5000, PbEvent.w10000, PbEvent.w20km, PbEvent.w35km, PbEvent.w50km, PbEvent.wHalf, PbEvent.wFull]
                                  .contains(race.raceType);
                              final dateString = race.date.toIso8601String().split('T')[0];
                              final query = <String, String>{
                                'date': dateString,
                                'menuName': race.name,
                                'isRace': 'true',
                                if (race.distance != null) 'distance': race.distance.toString(),
                                'activityType': isWalking ? 'walking' : 'running',
                              };
                              final uri = Uri(path: '/session/new', queryParameters: query);
                              context.push(uri.toString());
                            },
                          ),
                        ),
                      ));
                    }

                    // 2. 通常の予定
                    if (plans.isEmpty && race == null) {
                       items.add(const Card(child: ListTile(title: Text('予定はありません'))));
                    } else {
                       items.addAll(plans.map((p) {
                         final isRacePlan = p.isRace;
                         return Card(
                           color: isRacePlan ? Colors.orange.shade50 : null,
                           elevation: isRacePlan ? 2 : 1,
                           child: ListTile(
                             leading: isRacePlan ? const Text('🎯', style: TextStyle(fontSize: 24)) : null,
                             title: Text(p.menuName, style: TextStyle(fontWeight: isRacePlan ? FontWeight.bold : FontWeight.normal)),
                             subtitle: Text(_formatPlanSubtitle(p)),
                             trailing: Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 IconButton(
                                   icon: Icon(Icons.directions_run, color: isRacePlan ? Colors.orange : null),
                                   tooltip: '実績にする',
                                   onPressed: () => _copyToSession(context, p),
                                 ),
                                 const Icon(Icons.chevron_right),
                               ],
                             ),
                             onTap: () => context.push('/plan/edit?date=${dateKey.toIso8601String().split('T')[0]}'),
                           ),
                         );
                       }));
                    }

                    return Column(children: items);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('予定エラー: $e'),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('レースエラー: $e'),
            );
          },
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => context.push('/plan/edit?date=${dateKey.toIso8601String().split('T')[0]}'),
          icon: const Icon(Icons.event_note),
          label: const Text('予定を追加する'),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, '今日の実績 (${DateFormat('M月d日').format(dateKey)})'),
        sessionsAsync.when(
          data: (sessions) {
            if (sessions.isEmpty) return const Card(child: ListTile(title: Text('実績はありません')));
            return Column(
              children: sessions.map((s) {
                final tPace = s.activityType == ActivityType.walking ? wTpace : rTpace;
                final load = loadCalc.computeSessionRepresentativeLoad(
                  s,
                  thresholdPaceSecPerKm: tPace,
                  mode: loadMode,
                );
                final rpeEmoji = s.rpeValue != null && s.rpeValue! < _emojis.length ? _emojis[s.rpeValue!] : '';

                return Card(
                  child: ListTile(
                    leading: Text(rpeEmoji, style: const TextStyle(fontSize: 24)),
                    title: Text(s.templateText),
                    subtitle: Text(
                      '${(s.distanceMainM ?? 0) / 1000}km • ${_formatPace(s.paceSecPerKm)} • 負荷: ${(s.load ?? load ?? 0).round()}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/session/${s.id}'),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('エラー: $e'),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => context.push('/session/new?date=${dateKey.toIso8601String().split('T')[0]}'),
          icon: const Icon(Icons.add),
          label: const Text('実績を入力する'),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
        ),
      ],
    );
  }

  void _copyToSession(BuildContext context, Plan plan) {
    final dateString = plan.date.toIso8601String().split('T')[0];
    final query = <String, String>{
      'date': dateString,
      'menuName': plan.menuName,
      if (plan.distance != null) 'distance': plan.distance.toString(),
      if (plan.pace != null) 'pace': plan.pace.toString(),
      if (plan.zone != null) 'zone': plan.zone!.name,
      if (plan.reps > 1) 'reps': plan.reps.toString(),
      if (plan.note != null) 'note': plan.note!,
      'isRace': plan.isRace.toString(),
    };
    final uri = Uri(path: '/session/new', queryParameters: query);
    context.push(uri.toString());
  }

  String _formatPlanSubtitle(Plan p) {
    final segments = <String>[];
    if (p.distance != null) segments.add('${(p.distance! / 1000).toStringAsFixed(1)}km');
    if (p.reps > 1) segments.add('× ${p.reps}');
    if (p.pace != null) segments.add('@${_formatPace(p.pace)}');
    if (p.zone != null) segments.add('(${p.zone!.name})');
    return segments.join(' ');
  }

  String _formatPace(int? seconds) {
    if (seconds == null || seconds <= 0) return '-';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRaceCountdown(BuildContext context, String label, String name, int days, {required bool isMain}) {
    return Card(
      color: isMain ? Colors.amber.shade50 : Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Text(isMain ? '🏁' : '🎯', style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 10, color: isMain ? Colors.orange.shade900 : Colors.teal.shade900, fontWeight: FontWeight.bold)),
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('あと', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text('$days日', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: days == 0 ? Colors.red : (days <= 7 ? Colors.orange : Colors.teal))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
