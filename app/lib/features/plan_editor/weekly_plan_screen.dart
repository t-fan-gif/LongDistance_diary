import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/db/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/repos/plan_repository.dart';
import '../day_detail/day_detail_screen.dart';

final weeklyPlansProvider = FutureProvider.family<List<DailyPlanData>, DateTime>((ref, startDate) async {
  final repo = ref.watch(planRepositoryProvider);
  final results = <DailyPlanData>[];
  
  for (int i = 0; i < 7; i++) {
    final date = startDate.add(Duration(days: i));
    final plans = await repo.listPlansByDate(date);
    final memo = await repo.getDailyMemo(date);
    results.add(DailyPlanData(date, plans, memo?.note));
  }
  return results;
});

class DailyPlanData {
  final DateTime date;
  final List<Plan> plans;
  final String? memo;
  DailyPlanData(this.date, this.plans, this.memo);
}

class WeeklyPlanScreen extends ConsumerWidget {
  const WeeklyPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 今週の月曜日を取得
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    
    final weeklyAsync = ref.watch(weeklyPlansProvider(monday));

    return Scaffold(
      appBar: AppBar(
        title: const Text('トレーニング予定 (月〜日)'),
      ),
      body: weeklyAsync.when(
        data: (days) => ListView.builder(
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            return _WeeklyDayTile(day: day);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/plan/edit?date=${today.toIso8601String().split('T')[0]}'),
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class _WeeklyDayTile extends StatelessWidget {
  const _WeeklyDayTile({required this.day});
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
                ],
              ),
            ),
            const SizedBox(width: 16),
            // 内容部分
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (day.plans.isEmpty && (day.memo == null || day.memo!.isEmpty))
                    const Text('未定', style: TextStyle(color: Colors.grey, fontSize: 13))
                  else ...[
                    ...day.plans.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        children: [
                          Icon(
                            p.activityType == ActivityType.walking 
                              ? Icons.directions_walk 
                              : Icons.directions_run,
                            size: 14,
                            color: Colors.teal,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatPlanText(p),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
