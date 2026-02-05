import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/db_providers.dart';
import '../../core/domain/enums.dart';

class SummaryHistoryScreen extends ConsumerWidget {
  const SummaryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSessionsAsync = ref.watch(allSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('サマリー履歴'),
      ),
      body: allSessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text('データがありません'));
          }

          // 月別集計
          final monthlyData = <String, double>{};
          final monthlyLoad = <String, double>{};
          // 週別集計
          final weeklyData = <String, double>{};
          final weeklyLoad = <String, double>{};

          for (final s in sessions) {
            if (s.status == SessionStatus.skipped) continue;

            final date = s.startedAt;
            final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
            final distance = (s.distanceMainM ?? 0) / 1000.0;
            final load = s.load ?? 0.0;

            monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + distance;
            monthlyLoad[monthKey] = (monthlyLoad[monthKey] ?? 0) + load;

            // 週の開始日（月曜日）をキーにする
            final diffToMon = date.weekday - 1;
            final monday = DateTime(date.year, date.month, date.day).subtract(Duration(days: diffToMon));
            final weekEnd = monday.add(const Duration(days: 6));
            final weekKey = '${monday.year}-${monday.month.toString().padLeft(2, '0')}/${monday.day.toString().padLeft(2, '0')}~${weekEnd.month.toString().padLeft(2, '0')}/${weekEnd.day.toString().padLeft(2, '0')}';
            
            weeklyData[weekKey] = (weeklyData[weekKey] ?? 0) + distance;
            weeklyLoad[weekKey] = (weeklyLoad[weekKey] ?? 0) + load;
          }

          final sortedMonths = monthlyData.keys.toList()..sort((a, b) => b.compareTo(a));
          final sortedWeeks = weeklyData.keys.toList()..sort((a, b) => b.compareTo(a));

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: '月間サマリー'),
                    Tab(text: '週間サマリー'),
                  ],
                  labelColor: Colors.teal,
                  indicatorColor: Colors.teal,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildList(context, sortedMonths, monthlyData, monthlyLoad),
                      _buildList(context, sortedWeeks, weeklyData, weeklyLoad),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<String> keys, Map<String, double> distanceData, Map<String, double> loadData) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        final distance = distanceData[key]!;
        final load = loadData[key]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('距離: ${distance.toStringAsFixed(1)} km / 負荷: ${load.round()}'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        );
      },
    );
  }
}
