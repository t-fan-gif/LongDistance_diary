import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/db/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/repos/plan_repository.dart';
import '../day_detail/day_detail_screen.dart';
import '../calendar/calendar_providers.dart';
import '../settings/target_race_settings_screen.dart';

final weeklyPlansProvider = FutureProvider.family<List<DailyPlanData>, DateTimeRange>((ref, range) async {
  final planRepo = ref.watch(planRepositoryProvider);
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final results = <DailyPlanData>[];
  
  final daysCount = range.end.difference(range.start).inDays + 1;
  for (int i = 0; i < daysCount; i++) {
    final date = range.start.add(Duration(days: i));
    final plans = await planRepo.listPlansByDate(date);
    final memo = await planRepo.getDailyMemo(date);
    final sessions = await sessionRepo.listSessionsByDate(date);
    results.add(DailyPlanData(date, plans, memo?.note, sessions));
  }
  return results;
});

class DailyPlanData {
  final DateTime date;
  final List<Plan> plans;
  final String? memo;
  final List<Session> sessions;
  DailyPlanData(this.date, this.plans, this.memo, this.sessions);
  
  bool get hasSessions => sessions.isNotEmpty;
  bool get hasPlansOnly => plans.isNotEmpty && sessions.isEmpty;
}

class WeeklyPlanScreen extends ConsumerStatefulWidget {
  const WeeklyPlanScreen({super.key, this.isTab = true, this.tabController});
  final bool isTab;
  final TabController? tabController;

  @override
  ConsumerState<WeeklyPlanScreen> createState() => WeeklyPlanScreenState();
}

class WeeklyPlanScreenState extends ConsumerState<WeeklyPlanScreen> {
  late ScrollController _scrollController;
  final GlobalKey _todayKey = GlobalKey();


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // タブコントローラーのリスナー登録
    widget.tabController?.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (widget.tabController?.index == 1 && mounted) {
      // 遷移完了時（!indexIsChanging）または遷移開始時に一度だけ実行
      // リスナーは複数回呼ばれるため、タイミングを図る
      if (!widget.tabController!.indexIsChanging) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            scrollToToday(animate: false);
          }
        });
      }
    }
  }

  void scrollToToday({bool animate = true, int retryCount = 0}) {
    final context = _todayKey.currentContext;
    if (context != null) {
      if (animate) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
        );
      } else {
        Scrollable.ensureVisible(
          context,
          alignment: 0.0,
        );
      }
    } else if (retryCount < 10) {
      // コンテキストがまだ無い場合は待機（データロード待ちやビルド待ち）
      // 特に初回は時間がかかることがあるため、少し間隔を置いてリトライする
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && widget.tabController?.index == 1) {
          scrollToToday(animate: animate, retryCount: retryCount + 1);
        }
      });
    }
  }

  @override
  void dispose() {
    widget.tabController?.removeListener(_handleTabSelection);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 今日を起点に前後14日、計28日分を表示
    final today = DateUtils.dateOnly(DateTime.now());
    final startDate = today.subtract(const Duration(days: 14));
    final endDate = today.add(const Duration(days: 30));
    
    final weeklyAsync = ref.watch(weeklyPlansProvider(DateTimeRange(start: startDate, end: endDate)));

    // データのロードが完了した瞬間に、リストタブが表示されていればジャンプする
    ref.listen(weeklyPlansProvider(DateTimeRange(start: startDate, end: endDate)), (previous, next) {
      if (next is AsyncData && widget.tabController?.index == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            scrollToToday(animate: false);
          }
        });
      }
    });

    final content = weeklyAsync.when(
      data: (days) {
        return ListView.builder(
          controller: _scrollController,
          itemCount: days.length,
          cacheExtent: 5000, // 今日(14日目)が確実に出現するようにキャッシュ範囲を多めに確保
          itemBuilder: (context, index) {
            final day = days[index];
            // 月が変わる時に月ヘッダーを表示
            final showMonthHeader = index == 0 || 
                days[index - 1].date.month != day.date.month;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showMonthHeader)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.teal.shade100,
                    child: Text(
                      '${day.date.month}月',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                _WeeklyDayTile(
                  key: DateUtils.isSameDay(day.date, today) ? _todayKey : null,
                  day: day,
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
    );

    if (widget.isTab) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('トレーニングフロー'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: content,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/plan/edit?date=${today.toIso8601String().split('T')[0]}'),
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class _WeeklyDayTile extends StatelessWidget {
  const _WeeklyDayTile({super.key, required this.day});
  final DailyPlanData day;

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(day.date);
    final weekdayStr = ['月', '火', '水', '木', '金', '土', '日'][day.date.weekday - 1];
    
    return InkWell(
      onTap: () => context.push('/plan/edit?date=${day.date.toIso8601String().split('T')[0]}'),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          color: isToday ? Colors.teal.shade50 : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日付部分
            SizedBox(
              width: 50,
              child: Column(
                children: [
                  Text(
                    '${day.date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getDateColor(day.date),
                    ),
                  ),
                  Text(
                    '($weekdayStr)',
                    style: TextStyle(fontSize: 12, color: _getDateColor(day.date)),
                  ),
                  // レースマーカー
                  Consumer(
                    builder: (context, ref, child) {
                      final racesAsync = ref.watch(upcomingRacesProvider);
                      return racesAsync.maybeWhen(
                        data: (races) {
                          final isRaceDay = races.any((r) => 
                            r.date.year == day.date.year && 
                            r.date.month == day.date.month && 
                            r.date.day == day.date.day);
                          if (!isRaceDay) return const SizedBox.shrink();
                          return const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text('🏁', style: TextStyle(fontSize: 14)),
                          );
                        },
                        orElse: () => const SizedBox.shrink(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // 内容部分
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (day.plans.isEmpty && day.sessions.isEmpty && (day.memo == null || day.memo!.isEmpty))
                    const Text('未定', style: TextStyle(color: Colors.grey, fontSize: 13))
                  else ...[
                    // 実績（Session）を先に表示（濃い色）
                    ...day.sessions.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 14, color: Colors.teal),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatSessionText(s),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )),
                    // 予定（Plan）を薄い色で表示（実績がない場合のみ）
                    if (!day.hasSessions)
                      ...day.plans.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        children: [
                          // Icon(
                          //   p.activityType == ActivityType.walking 
                          //     ? Icons.directions_walk 
                          //     : Icons.directions_run,
                          //   size: 14,
                          //   color: Colors.teal,
                          // ),
                          // const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatPlanText(p),
                              style: TextStyle(
                                fontSize: 13, 
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600, // 予定は薄い色
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )),
                    if (day.memo != null && day.memo!.isNotEmpty)
                      Text(
                        '📝 ${day.memo}',
                        style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  String _formatPlanText(Plan p) {
    if (p.menuName == 'レスト') return 'レスト';
    final parts = <String>[p.menuName];
    if (p.distance != null) {
      final km = (p.distance! / 1000).toStringAsFixed(1);
      final reps = p.reps > 1 ? 'x${p.reps}' : '';
      parts.add('$km$reps');
    }
    if (p.pace != null) {
      final m = p.pace! ~/ 60;
      final s = p.pace! % 60;
      parts.add('@$m:${s.toString().padLeft(2, '0')}');
    }
    return parts.join(' ');
  }

  String _formatSessionText(Session s) {
    if (s.templateText == 'レスト') return 'レスト';
    final parts = <String>[s.templateText];
    if (s.distanceMainM != null && s.distanceMainM! > 0) {
      final km = (s.distanceMainM! / 1000).toStringAsFixed(1);
      parts.add('${km}km');
    }
    if (s.paceSecPerKm != null) {
      final m = s.paceSecPerKm! ~/ 60;
      final sec = s.paceSecPerKm! % 60;
      parts.add('@$m:${sec.toString().padLeft(2, '0')}');
    }
    return parts.join(' ');
  }

  Color _getDateColor(DateTime date) {
    if (date.weekday == 7) return Colors.red;
    if (date.weekday == 6) return Colors.blue;
    return Colors.black87;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year && now.month == date.month && now.day == date.day;
  }
}
