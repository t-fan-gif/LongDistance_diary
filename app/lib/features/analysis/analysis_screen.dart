import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/domain/enums.dart';
import '../../core/services/load_calculator.dart';
import '../calendar/calendar_providers.dart';
import '../history/history_list_screen.dart';
import '../settings/advanced_settings_screen.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(allSessionsProvider);
    final loadCalc = ref.watch(loadCalculatorProvider);
    final rTpace = ref.watch(runningThresholdPaceProvider).valueOrNull;
    final wTpace = ref.watch(walkingThresholdPaceProvider).valueOrNull;
    final loadMode = ref.watch(loadCalculationModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('トレーニング分析'),
        leading: const BackButton(),
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text('データがありません'));
          }

          // 週・月ごとの集計
          final weeklyData = <String, double>{};
          final monthlyData = <String, double>{};
          final weeklyLoad = <String, int>{};
          final monthlyLoad = <String, int>{};

          for (final s in sessions) {
            final tPace = s.activityType == ActivityType.walking ? wTpace : rTpace;
            final load = loadCalc.computeSessionRepresentativeLoad(
              s,
              thresholdPaceSecPerKm: tPace,
              mode: loadMode,
            ) ?? 0;
            final distKm = (s.distanceMainM ?? 0) / 1000.0;
            
            // 月キー: yyyy-MM
            final monthKey = '${s.startedAt.year}-${s.startedAt.month.toString().padLeft(2, '0')}';
            monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + distKm;
            monthlyLoad[monthKey] = (monthlyLoad[monthKey] ?? 0) + load;

            // 週キー: IDOW (Year-Week)
            // 簡易的に月曜開始の週番号を使用
            final weekNum = _getWeekOfYear(s.startedAt);
            final weekKey = '${s.startedAt.year}-W$weekNum';
            weeklyData[weekKey] = (weeklyData[weekKey] ?? 0) + distKm;
            weeklyLoad[weekKey] = (weeklyLoad[weekKey] ?? 0) + load;
          }

          final sortedWeeks = weeklyData.keys.toList()..sort((a, b) => b.compareTo(a));
          final sortedMonths = monthlyData.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle(context, '月間サマリー'),
              ...sortedMonths.take(6).map((month) => _buildStatCard(
                context,
                month,
                monthlyData[month]!,
                monthlyLoad[month]!,
              )),
              const SizedBox(height: 24),
              _buildSectionTitle(context, '週間サマリー'),
              ...sortedWeeks.take(8).map((week) => _buildStatCard(
                context,
                week,
                weeklyData[week]!,
                weeklyLoad[week]!,
              )),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
      ),
    );
  }

  int _getWeekOfYear(DateTime date) {
    // 簡易的な週番号計算
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
