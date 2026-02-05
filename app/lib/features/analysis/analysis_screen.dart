import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/domain/enums.dart';
import '../../core/db/app_database.dart';
import '../../core/services/vdot_calculator.dart';
import '../../core/services/load_calculator.dart';
import '../../core/services/service_providers.dart';
import '../../core/services/analysis_service.dart';
import '../calendar/calendar_providers.dart';
import '../history/history_list_screen.dart';
import '../settings/advanced_settings_screen.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawerEnableOpenDragGesture: false,
        appBar: AppBar(
          title: const Text('トレーニング分析'),
          leading: const BackButton(),
          bottom: const TabBar(
            tabs: [
              Tab(text: '集計'),
              Tab(text: '分析 (CTL/ATL)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SummaryTab(),
            _TrendsTab(),
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

        final weeklyData = <String, double>{};
        final monthlyData = <String, double>{};
        final weeklyLoad = <String, int>{};
        final monthlyLoad = <String, int>{};

        for (final s in sessions) {
          final tPace = s.activityType == ActivityType.walking ? wTpace : rTpace;
          final calculatedLoad = loadCalc.computeSessionRepresentativeLoad(
            s,
            thresholdPaceSecPerKm: tPace,
            mode: loadMode,
          );
          final load = (calculatedLoad?.toDouble() ?? s.load ?? 0).round();
          final distKm = (s.distanceMainM ?? 0) / 1000.0;
          
          final monthKey = '${s.startedAt.year}-${s.startedAt.month.toString().padLeft(2, '0')}';
          monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + distKm;
          monthlyLoad[monthKey] = (monthlyLoad[monthKey] ?? 0) + load;

          final weekNum = _getWeekOfYear(s.startedAt);
          final weekKey = '${s.startedAt.year}-W$weekNum';
          weeklyData[weekKey] = (weeklyData[weekKey] ?? 0) + distKm;
          weeklyLoad[weekKey] = (weeklyLoad[weekKey] ?? 0) + load;
        }

        final sortedWeeks = weeklyData.keys.toList()..sort((a, b) => b.compareTo(a));
        final sortedMonths = monthlyData.keys.toList()..sort((a, b) => b.compareTo(a));

        // 現在の月・週のデータを取得
        final now = DateTime.now();
        final currentMonthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        final currentWeekKey = '${now.year}-W${_getWeekOfYear(now)}';
        
        final currentMonthDist = monthlyData[currentMonthKey] ?? 0;
        final currentWeekDist = weeklyData[currentWeekKey] ?? 0;
        
        final monthlyGoal = ref.watch(monthlyDistanceGoalProvider);
        final weeklyGoal = ref.watch(weeklyDistanceGoalProvider);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle(context, '目標進捗'),
            _buildGoalCard(context, '今月の走行距離', currentMonthDist, monthlyGoal),
            _buildGoalCard(context, '今週の走行距離', currentWeekDist, weeklyGoal),
            const SizedBox(height: 24),
            _buildSectionTitle(context, '月間サマリー'),
            ...sortedMonths.take(6).map((month) => _buildStatCard(context, month, monthlyData[month]!, monthlyLoad[month]!)),
            const SizedBox(height: 24),
            _buildSectionTitle(context, '週間サマリー'),
            ...sortedWeeks.take(8).map((week) => _buildStatCard(context, week, weeklyData[week]!, weeklyLoad[week]!)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
    );
  }

  Widget _buildGoalCard(BuildContext context, String title, double current, double goal) {
    final progress = (current / goal).clamp(0.0, 1.0);
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
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(progress * 100).toInt()}% 達成',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
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
    final sessionsAsync = ref.watch(allSessionsProvider);
    final analysisService = ref.watch(analysisServiceProvider);
    final vdotCalc = ref.watch(vdotCalculatorProvider);

    return sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) return const Center(child: Text('データが不足しています'));

        final trends = analysisService.calculateTrends(sessions);
        if (trends.isEmpty) return const Center(child: Text('分析のためのデータが蓄積されていません（42日以上の記録が必要です）'));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPredictionSection(ref, sessions, vdotCalc, analysisService),
            const SizedBox(height: 24),
            _buildTrendSection(context, trends),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
    );
  }

  Widget _buildPredictionSection(WidgetRef ref, List<Session> sessions, VdotCalculator vdotCalc, AnalysisService analysisService) {
    return FutureBuilder<double?>(
      future: analysisService.estimateCurrentVdot(sessions),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('直近30日のポイント練習データからパフォーマンスを推定します。'),
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
                    const Text('推定パフォーマンス(VDOT)', style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.teal.shade100, borderRadius: BorderRadius.circular(12)),
                      child: Text(currentVdot.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    ),
                  ],
                ),
                const Text('直近の強度の高い練習から推定されるレース予測タイム', style: TextStyle(fontSize: 11, color: Colors.grey)),
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
        const Text('CTL(青): 長期的な走力 / ATL(赤): 短期的な疲労', style: TextStyle(fontSize: 11, color: Colors.grey)),
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
                  spots: trends.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.ctl)).toList(),
                  color: Colors.blue,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: Colors.blue.withValues(alpha: 0.1)),
                ),
                LineChartBarData(
                  spots: trends.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.atl)).toList(),
                  color: Colors.red,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
