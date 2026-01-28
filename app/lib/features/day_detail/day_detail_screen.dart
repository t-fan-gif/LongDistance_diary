import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/services/load_calculator.dart';
import '../calendar/calendar_providers.dart';

/// 選択された日付のプロバイダ
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);

/// 指定日のセッション一覧
final daySessionsProvider = FutureProvider.family<List<Session>, DateTime>(
  (ref, date) async {
    final repo = ref.watch(sessionRepositoryProvider);
    return repo.listSessionsByDate(date);
  },
);

/// 指定日のプラン一覧
final dayPlansProvider = FutureProvider.family<List<Plan>, DateTime>(
  (ref, date) async {
    final repo = ref.watch(planRepositoryProvider);
    return repo.listPlansByDate(date);
  },
);

class DayDetailScreen extends ConsumerWidget {
  const DayDetailScreen({super.key, required this.dateString});

  final String dateString;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.parse(dateString);
    final sessionsAsync = ref.watch(daySessionsProvider(date));
    final plansAsync = ref.watch(dayPlansProvider(date));
    final loadCalc = LoadCalculator();

    return Scaffold(
      appBar: AppBar(
        title: Text(_formatDate(date)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日負荷サマリー
          sessionsAsync.when(
            data: (sessions) {
              final dayLoad = loadCalc.computeDayLoad(sessions);
              return Container(
                padding: const EdgeInsets.all(16),
                color: Colors.teal.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '日負荷: $dayLoad',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'セッション: ${sessions.length}件',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('エラー: $e'),
          ),

          // 予定セクション
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '予定',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: () {
                    context.push('/plan/edit?date=$dateString');
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('追加'),
                ),
              ],
            ),
          ),
          plansAsync.when(
            data: (plans) {
              if (plans.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('予定はありません', style: TextStyle(color: Colors.grey)),
                );
              }
              return Column(
                children: plans.map((plan) => _PlanTile(plan: plan, dateString: dateString)).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('エラー: $e'),
          ),

          const Divider(),

          // 実績セクション
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '実績',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: () {
                    context.push('/session/new?date=$dateString');
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('追加'),
                ),
              ],
            ),
          ),
          Expanded(
            child: sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return const Center(
                    child: Text('実績はありません', style: TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    return _SessionTile(session: sessions[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('エラー: $e')),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    return '${date.month}月${date.day}日（${weekdays[date.weekday % 7]}）';
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.plan, required this.dateString});

  final Plan plan;
  final String dateString;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.event_note, color: Colors.teal),
      title: Text(plan.menuName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (plan.distance != null)
                Text('${(plan.distance! / 1000).toStringAsFixed(1)}km '),
              if (plan.reps > 1) Text('× ${plan.reps} '),
              if (plan.pace != null) Text('@${_formatPace(plan.pace!)} '),
              if (plan.zone != null) Text('(${plan.zone!.name}) '),
            ],
          ),
          if (plan.note != null && plan.note!.isNotEmpty)
            Text(plan.note!, style: const TextStyle(fontSize: 12)),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.directions_run),
        tooltip: '実績にする',
        onPressed: () => _copyToSession(context),
      ),
      onTap: () {
        // 同じ日ならまとめて編集画面へ
        context.push('/plan/edit?date=${plan.date.toIso8601String().split('T')[0]}');
      },
    );
  }

  void _copyToSession(BuildContext context) {
    final query = <String, String>{
      'date': dateString,
      'menuName': plan.menuName,
      if (plan.distance != null) 'distance': plan.distance.toString(),
      if (plan.pace != null) 'pace': plan.pace.toString(),
      if (plan.zone != null) 'zone': plan.zone!.name,
      if (plan.reps > 1) 'reps': plan.reps.toString(),
      if (plan.note != null) 'note': plan.note!,
    };
    final uri = Uri(path: '/session/new', queryParameters: query);
    context.push(uri.toString());
  }

  String _formatPace(int secPerKm) {
    final min = secPerKm ~/ 60;
    final sec = secPerKm % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final loadCalc = LoadCalculator();
    final load = loadCalc.computeSessionRepresentativeLoad(session);

    return ListTile(
      leading: _buildStatusIcon(),
      title: Text(session.templateText),
      subtitle: Row(
        children: [
          if (session.distanceMainM != null)
            Text('${(session.distanceMainM! / 1000).toStringAsFixed(1)}km '),
          if (session.paceSecPerKm != null) Text('${_formatPace(session.paceSecPerKm!)} '),
          if (session.zone != null) Text('@${session.zone!.name} '),
          if (load != null) Text('負荷: $load'),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.push('/session/${session.id}');
      },
    );
  }

  Widget _buildStatusIcon() {
    switch (session.status) {
      case SessionStatus.done:
        return const Icon(Icons.check_circle, color: Colors.green);
      case SessionStatus.partial:
        return const Icon(Icons.timelapse, color: Colors.orange);
      case SessionStatus.aborted:
        return const Icon(Icons.cancel, color: Colors.red);
      case SessionStatus.skipped:
        return const Icon(Icons.skip_next, color: Colors.grey);
    }
  }

  String _formatPace(int secPerKm) {
    final min = secPerKm ~/ 60;
    final sec = secPerKm % 60;
    return '$min:${sec.toString().padLeft(2, '0')}/km';
  }
}
