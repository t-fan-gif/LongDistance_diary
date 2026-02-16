import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/domain/enums.dart';
import '../../core/db/db_providers.dart';
import '../../core/db/app_database.dart';
import '../../core/services/vdot_calculator.dart';
import '../../core/services/load_calculator.dart';
import '../../core/services/service_providers.dart';
import '../../core/services/analysis_service.dart';
import '../calendar/calendar_providers.dart';
import '../settings/advanced_settings_screen.dart';
import '../settings/goal_providers.dart';
import '../settings/target_race_settings_screen.dart';

final monthlyPlanDistanceProvider = FutureProvider<double>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 1);
  final plans = await (db.select(db.plans)
    ..where((t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end)))
    .get();
  return plans.fold<double>(0.0, (sum, e) => sum + (e.distance ?? 0) / 1000.0);
});

final weeklyPlanDistanceProvider = FutureProvider<double>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final now = DateTime.now();
  // 週の開始（月曜日）を計算
  final start = now.subtract(Duration(days: now.weekday - 1));
  final startDay = DateTime(start.year, start.month, start.day);
  final endDay = startDay.add(const Duration(days: 7));
  
  final plans = await (db.select(db.plans)
    ..where((t) => t.date.isBiggerOrEqualValue(startDay) & t.date.isSmallerThanValue(endDay)))
    .get();
  return plans.fold<double>(0.0, (sum, e) => sum + (e.distance ?? 0) / 1000.0);
});

final monthlyPlanPredictedLoadProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final analysis = ref.watch(analysisServiceProvider);
  final rTpace = ref.watch(runningThresholdPaceProvider).valueOrNull;
  final wTpace = ref.watch(walkingThresholdPaceProvider).valueOrNull;

  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 1);
  final plans = await (db.select(db.plans)
    ..where((t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end)))
    .get();
    
  int total = 0;
  for (final plan in plans) {
    total += await analysis.predictPlanLoadWithPace(
      plan, 
      runningThresholdPace: rTpace, 
      walkingThresholdPace: wTpace
    );
  }
  return total;
});

final weeklyPlanPredictedLoadProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final analysis = ref.watch(analysisServiceProvider);
  final rTpace = ref.watch(runningThresholdPaceProvider).valueOrNull;
  final wTpace = ref.watch(walkingThresholdPaceProvider).valueOrNull;

  final now = DateTime.now();
  final start = now.subtract(Duration(days: now.weekday - 1));
  final startDay = DateTime(start.year, start.month, start.day);
  final endDay = startDay.add(const Duration(days: 7));
  
  final plans = await (db.select(db.plans)
    ..where((t) => t.date.isBiggerOrEqualValue(startDay) & t.date.isSmallerThanValue(endDay)))
    .get();
    
  int total = 0;
  for (final plan in plans) {
    total += await analysis.predictPlanLoadWithPace(
      plan, 
      runningThresholdPace: rTpace, 
      walkingThresholdPace: wTpace
    );
  }
  return total;
});

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawerEnableOpenDragGesture: false,
        appBar: AppBar(
          title: const Text('トレーニング分析'),
          leading: const BackButton(),
          bottom: const TabBar(
            tabs: [
              Tab(text: '集計'),
              Tab(text: '解析'),
              Tab(text: 'レース'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SummaryTab(),
            _TrendsTab(),
            _RaceHistoryTab(),
          ],
        ),
      ),
    );
  }
}

class _SummaryTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(allSessionsProvider);
    final loadCalc = ref.watch(loadCalculatorProvider);
    final rTpace = ref.watch(runningThresholdPaceProvider).valueOrNull;
    final wTpace = ref.watch(walkingThresholdPaceProvider).valueOrNull;
    final loadMode = ref.watch(loadCalculationModeProvider);

    return sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return const Center(child: Text('データがありません'));
        }

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final thirtyDaysAgo = today.subtract(const Duration(days: 30));

        double last30DaysDist = 0;
        int last30DaysLoad = 0;

        // 週別集計用のMap (月曜日開始)
        final weeklyStats = <String, (double, int)>{};
        final last4WeeksKeys = <String>[];

        // 直近4週間のキーを生成
        final diffToMon = now.weekday - 1;
        DateTime monday = today.subtract(Duration(days: diffToMon));
        for (int i = 0; i < 4; i++) {
          final weekStart = monday.subtract(Duration(days: 7 * i));
          final weekEnd = weekStart.add(const Duration(days: 6));
          final key = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}/${weekStart.day.toString().padLeft(2, '0')}~${weekEnd.month.toString().padLeft(2, '0')}/${weekEnd.day.toString().padLeft(2, '0')}';
          last4WeeksKeys.add(key);
          weeklyStats[key] = (0.0, 0);
        }

        for (final s in sessions) {
          if (s.status == SessionStatus.skipped) continue;

          final tPace = s.activityType == ActivityType.walking ? wTpace : rTpace;
          final calculatedLoad = loadCalc.computeSessionRepresentativeLoad(
            s,
            thresholdPaceSecPerKm: tPace,
            mode: loadMode,
          );
          final load = (calculatedLoad?.toDouble() ?? s.load ?? 0).round();
          final distKm = (s.distanceMainM ?? 0) / 1000.0;

          // 直近30日間
          if (s.startedAt.isAfter(thirtyDaysAgo)) {
            last30DaysDist += distKm;
            last30DaysLoad += load;
          }

          // 週別 (直近4週間に該当するか確認)
          final sDate = s.startedAt;
          final sMonday = DateTime(sDate.year, sDate.month, sDate.day).subtract(Duration(days: sDate.weekday - 1));
          final sEnd = sMonday.add(const Duration(days: 6));
          final sKey = '${sMonday.year}-${sMonday.month.toString().padLeft(2, '0')}/${sMonday.day.toString().padLeft(2, '0')}~${sEnd.month.toString().padLeft(2, '0')}/${sEnd.day.toString().padLeft(2, '0')}';

          if (weeklyStats.containsKey(sKey)) {
            final current = weeklyStats[sKey]!;
            weeklyStats[sKey] = (current.$1 + distKm, current.$2 + load);
          }
        }

        // 現在の月・週のデータを取得 (目標進捗用はカレンダー月/週で維持)
        final currentMonthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        final currentWeekNum = _getWeekOfYear(now);
        final currentWeekKey = '${now.year}-W$currentWeekNum';

        // 目標進捗用の今月・今週分を別途集計
        double curMonthDist = 0;
        double curWeekDist = 0;
        int curMonthLoad = 0; // 実績負荷
        int curWeekLoad = 0;  // 実績負荷
        
        for (final s in sessions) {
          if (s.status == SessionStatus.skipped) continue;
          final distKm = (s.distanceMainM ?? 0) / 1000.0;
          final tPace = s.activityType == ActivityType.walking ? wTpace : rTpace;
          final load = (loadCalc.computeSessionRepresentativeLoad(s, thresholdPaceSecPerKm: tPace, mode: loadMode) ?? 0);
          
          if ('${s.startedAt.year}-${s.startedAt.month.toString().padLeft(2, '0')}' == currentMonthKey) {
            curMonthDist += distKm;
            curMonthLoad += load;
          }
          if ('${s.startedAt.year}-W${_getWeekOfYear(s.startedAt)}' == currentWeekKey) {
            curWeekDist += distKm;
            curWeekLoad += load;
          }
        }
        
        final monthlyGoal = ref.watch(monthlyDistanceGoalProvider);
        final weeklyGoal = ref.watch(weeklyDistanceGoalProvider);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle(context, '目標進捗'),
                TextButton.icon(
                  onPressed: () => context.push('/settings/goals'),
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('目標設定', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            _buildGoalCard(
              context, 
              '今月の走行距離', 
              curMonthDist, 
              monthlyGoal > 0 ? monthlyGoal : ref.watch(monthlyPlanDistanceProvider).valueOrNull ?? 0,
              planTotal: ref.watch(monthlyPlanDistanceProvider).valueOrNull,
              planLoad: ref.watch(monthlyPlanPredictedLoadProvider).valueOrNull,
              currentLoad: curMonthLoad,
            ),
            _buildGoalCard(
              context, 
              '今週の走行距離', 
              curWeekDist, 
              weeklyGoal > 0 ? weeklyGoal : ref.watch(weeklyPlanDistanceProvider).valueOrNull ?? 0,
              planTotal: ref.watch(weeklyPlanDistanceProvider).valueOrNull,
              planLoad: ref.watch(weeklyPlanPredictedLoadProvider).valueOrNull,
              currentLoad: curWeekLoad,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'サマリー'),
            _buildStatCard(context, '直近30日間', last30DaysDist, last30DaysLoad),
            const Divider(),
            ...last4WeeksKeys.map((key) {
               final stats = weeklyStats[key]!;
               return _buildStatCard(context, key, stats.$1, stats.$2);
            }),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () => context.push('/history'),
                icon: const Icon(Icons.history),
                label: const Text('サマリー履歴（月別・週別）を見る'),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
    );
  }

  Widget _buildGoalCard(BuildContext context, String title, double current, double goal, {double? planTotal, int? planLoad, int? currentLoad}) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${current.toStringAsFixed(1)} / ${goal.toInt()} km',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.teal.shade50,
              color: Colors.teal,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toInt()}% 達成',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                if (planTotal != null && planTotal > 0)
                  Row(
                    children: [
                      Text(
                        '予定合計: ${planTotal.toStringAsFixed(1)}km',
                        style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontStyle: FontStyle.italic),
                      ),
                      if (planLoad != null)
                         Text(
                          ' (予測負荷: $planLoad)',
                          style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontStyle: FontStyle.italic),
                         ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _getWeekOfYear(DateTime date) {
    final dayOfYear = int.parse(DateFormat('D').format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, double dist, int load) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                _buildStatItem('距離', '${dist.toStringAsFixed(1)}km'),
                const SizedBox(width: 16),
                _buildStatItem('負荷', '$load'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _TrendsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionRepo = ref.watch(sessionRepositoryProvider);
    final analysisService = ref.watch(analysisServiceProvider);
    final vdotCalc = ref.watch(vdotCalculatorProvider);
    
    // パラメータの監視
    final mode = ref.watch(loadCalculationModeProvider);
    final rPaceAsync = ref.watch(runningThresholdPaceProvider);
    final wPaceAsync = ref.watch(walkingThresholdPaceProvider);

    return ref.watch(allSessionsProvider).when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return const Center(child: Text('データがありません'));
        }

        // パラメータが揃うまで待つか、デフォルト値で計算
        final rPace = rPaceAsync.valueOrNull;
        final wPace = wPaceAsync.valueOrNull;

        final trends = analysisService.calculateTrends(
          sessions,
          mode: mode,
          runningThresholdPace: rPace,
          walkingThresholdPace: wPace,
        );
        if (trends.isEmpty) return const Center(child: Text('分析のためのデータが蓄積されていません（42日以上の記録が必要です）'));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPredictionSection(ref, sessions, vdotCalc, analysisService, ActivityType.running),
            const SizedBox(height: 16),
            _buildPredictionSection(ref, sessions, vdotCalc, analysisService, ActivityType.walking),
            const SizedBox(height: 24),
            _buildTrendSection(context, trends),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
    );
  }

  Widget _buildPredictionSection(WidgetRef ref, List<Session> sessions, VdotCalculator vdotCalc, AnalysisService analysisService, ActivityType type) {
    final typeSessions = sessions.where((s) => s.activityType == type).toList();
    
    return FutureBuilder<double?>(
      future: analysisService.estimateCurrentVdot(typeSessions),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${type.label}: 直近30日のポイント練習データからパフォーマンスを推定します。',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          );
        }

        final currentVdot = snapshot.data!;
        final predictions = vdotCalc.predictTimes(currentVdot);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${type.label} 推定パフォーマンス', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.teal.shade100, borderRadius: BorderRadius.circular(12)),
                      child: Text('VDOT ${currentVdot.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13)),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text('※試験実装中: レース予測タイム', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    SizedBox(width: 4),
                    Tooltip(
                      message: '直近の強度の高い練習から推定される目安です。',
                      child: Icon(Icons.info_outline, size: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const Divider(),
                ...predictions.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key.label, style: const TextStyle(fontSize: 13)),
                      Text(_formatDuration(e.value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(int totalSec) {
    final h = totalSec ~/ 3600;
    final m = (totalSec % 3600) ~/ 60;
    final s = totalSec % 60;
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildTrendSection(BuildContext context, List<TrainingLoadData> trends) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('トレーニング負荷の推移', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Text('CTL(青): 長期的な走力 / ATL(赤): 短期的な疲労 / TSB(緑): コンディション', style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 14, // 2週間ごと
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < 0 || value.toInt() >= trends.length) return const SizedBox.shrink();
                      final date = trends[value.toInt()].date;
                      return Text('${date.month}/${date.day}', style: const TextStyle(fontSize: 10, color: Colors.grey));
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
              lineBarsData: [
                LineChartBarData(
                  spots: trends.asMap().entries.map((e) => FlSpot(e.key.toDouble(), double.parse(e.value.ctl.toStringAsFixed(1)))).toList(),
                  color: Colors.blue,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: Colors.blue.withValues(alpha: 0.1)),
                ),
                LineChartBarData(
                  spots: trends.asMap().entries.map((e) => FlSpot(e.key.toDouble(), double.parse(e.value.atl.toStringAsFixed(1)))).toList(),
                  color: Colors.red,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: trends.asMap().entries.map((e) => FlSpot(e.key.toDouble(), double.parse(e.value.tsb.toStringAsFixed(1)))).toList(),
                  color: Colors.green,
                  dotData: const FlDotData(show: false),
                  dashArray: [5, 5],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RaceHistoryTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(allSessionsProvider);

    return sessionsAsync.when(
      data: (sessions) {
        final races = sessions.where((s) => s.isRace).toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));

        if (races.isEmpty) {
          return const Center(child: Text('レースの記録がありません'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: races.length,
          itemBuilder: (context, index) {
            final race = races[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.amber),
                title: Text(race.templateText, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat('yyyy/MM/dd').format(race.startedAt)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(race.distanceMainM ?? 0) / 1000}km',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (race.durationMainSec != null)
                      Text(
                        _formatDuration(race.durationMainSec!),
                        style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(race.templateText),
                        content: Text('${DateFormat('yyyy/MM/dd').format(race.startedAt)}\n距離: ${(race.distanceMainM ?? 0) / 1000}km\nタイム: ${race.durationMainSec != null ? _formatDuration(race.durationMainSec!) : "-"}'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('閉じる')),
                          TextButton(onPressed: () { 
                            Navigator.pop(context);
                            context.push('/session/${race.id}');
                          }, child: const Text('編集')),
                        ],
                      ),
                    );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
    );
  }

  String _formatDuration(int totalSec) {
    final h = totalSec ~/ 3600;
    final m = (totalSec % 3600) ~/ 60;
    final s = totalSec % 60;
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
