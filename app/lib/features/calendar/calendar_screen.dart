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
              return const Expanded(child: SizedBox(height: 100));
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
        height: 100,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          border: isToday
              ? Border.all(color: Colors.teal, width: 2)
              : Border.all(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. 日付とバッジ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    '${data.date.day}',
                     style: TextStyle(
                      fontSize: 10,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? Colors.teal : null,
                    ),
                  ),
                  if (data.sessionCount > 0)
                    _buildBadge('${data.sessionCount}', Colors.teal, Colors.white)
                  else if (data.planCount > 0)
                     _buildBadge('${data.planCount}', Colors.transparent, Colors.teal, isBorder: true),
                ],
              ),
              const Spacer(),
              // 2. メニュー名
              if (_hasMenu()) 
                Text(
                  _getMenuName(),
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, height: 1.0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              // 3. メニュー内容 (距離 @ペース)
              if (_hasContent())
                Text(
                  _getContentText(),
                  style: const TextStyle(fontSize: 8, height: 1.0, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              const Spacer(),
              // 4. トータル距離
              if (data.totalDistanceM > 0)
                Text(
                  '${(data.totalDistanceM / 1000).toStringAsFixed(1)}km',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor, {bool isBorder = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: isBorder ? Border.all(color: textColor, width: 0.5) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  bool _hasMenu() => data.maxLoadSession != null || data.plans.isNotEmpty;

  String _getMenuName() {
    if (data.maxLoadSession != null) return data.maxLoadSession!.templateText;
    if (data.plans.isNotEmpty) return data.plans.first.menuName;
    return '';
  }

  bool _hasContent() {
    if (data.maxLoadSession != null) {
      return data.maxLoadSession!.distanceMainM != null || data.maxLoadSession!.paceSecPerKm != null;
    }
    if (data.plans.isNotEmpty) return true;
    return false;
  }

  String _getContentText() {
    if (data.maxLoadSession != null) {
      final s = data.maxLoadSession!;
      final dist = s.distanceMainM != null ? '${(s.distanceMainM! / 1000).toStringAsFixed(1)}k' : '';
      final pace = s.paceSecPerKm != null ? '@${_formatPace(s.paceSecPerKm!)}' : '';
      return '$dist$pace';
    }
    if (data.plans.isNotEmpty) {
      final p = data.plans.first;
      final dist = (p.distance ?? 0) > 0 ? '${(p.distance! / 1000).toStringAsFixed(1)}k' : '';
      final pace = p.pace != null ? '@${_formatPace(p.pace!)}' : '';
      return '$dist$pace';
    }
    return '';
  }

  String _formatPace(int secPerKm) {
    final min = secPerKm ~/ 60;
    final sec = (secPerKm % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
