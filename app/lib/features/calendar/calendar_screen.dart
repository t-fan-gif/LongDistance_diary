import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/heatmap_scaler.dart';
import 'calendar_providers.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final calendarDataAsync = ref.watch(monthCalendarDataProvider(selectedMonth));

    return Scaffold(
      appBar: AppBar(
        title: const Text('カレンダー'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 月選択ヘッダー
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 今日の日付で予定作成
          final today = DateTime.now();
          context.push('/plan/edit?date=${today.toIso8601String().split('T')[0]}');
        },
        child: const Icon(Icons.add),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPreviousMonth,
          ),
          Text(
            '${selectedMonth.year}年${selectedMonth.month}月',
            style: Theme.of(context).textTheme.titleLarge,
          ),
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
  const _WeekdayHeader();

  static const _weekdays = ['日', '月', '火', '水', '木', '金', '土'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: _weekdays.map((day) {
          final isWeekend = day == '日' || day == '土';
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isWeekend ? Colors.red.shade400 : null,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({required this.days});

  final List<DayCalendarData> days;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return const Center(child: Text('データがありません'));
    }

    // 月初の曜日を取得（0=日曜日）
    final firstDayOfMonth = days.first.date;
    final firstWeekday = firstDayOfMonth.weekday % 7; // 日曜日=0に変換

    // グリッドに空白セルを追加
    final List<DayCalendarData?> cells = [
      ...List.filled(firstWeekday, null),
      ...days,
    ];

    // 週ごとにグループ化
    final weeks = <List<DayCalendarData?>>[];
    for (int i = 0; i < cells.length; i += 7) {
      weeks.add(cells.sublist(i, (i + 7).clamp(0, cells.length)));
    }

    return ListView.builder(
      itemCount: weeks.length,
      itemBuilder: (context, weekIndex) {
        final week = weeks[weekIndex];
        return Row(
          children: List.generate(7, (dayIndex) {
            if (dayIndex >= week.length || week[dayIndex] == null) {
              return const Expanded(child: SizedBox(height: 80));
            }
            return Expanded(
              child: _DayCell(data: week[dayIndex]!),
            );
          }),
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.data});

  final DayCalendarData data;

  @override
  Widget build(BuildContext context) {
    final heatmapScaler = HeatmapScaler();
    final bgColor = heatmapScaler.getColorForBucket(data.heatmapBucket);
    final isToday = _isToday(data.date);

    return GestureDetector(
      onTap: () {
        context.push('/day/${data.date.toIso8601String().split('T')[0]}');
      },
      child: Container(
        height: 80,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          border: isToday
              ? Border.all(color: Colors.teal, width: 2)
              : Border.all(color: Colors.grey.shade200),
        ),
        child: Stack(
          children: [
            // 日付
            Positioned(
              top: 4,
              left: 4,
              child: Text(
                '${data.date.day}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? Colors.teal : null,
                ),
              ),
            ),
            // セッション数バッジ
            if (data.sessionCount > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${data.sessionCount}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            // 予定のみの場合は枠線で表示
            if (data.sessionCount == 0 && data.planCount > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${data.planCount}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            // メニュー表示（最大負荷のセッション、なければ最初のプラン）
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: _buildMenuLabel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuLabel() {
    String? label;
    if (data.maxLoadSession != null) {
      label = data.maxLoadSession!.templateText;
    } else if (data.plans.isNotEmpty) {
      label = data.plans.first.menuName;
    }

    if (label == null) return const SizedBox.shrink();

    // 長い場合は省略
    if (label.length > 10) {
      label = '${label.substring(0, 10)}…';
    }

    return Text(
      label,
      style: const TextStyle(fontSize: 10),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
