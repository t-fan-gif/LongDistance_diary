import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/db/app_database.dart';
import '../../core/db/db_providers.dart';
import '../../core/domain/enums.dart';
import '../../core/services/load_calculator.dart';
import '../calendar/calendar_providers.dart';

final allSessionsProvider = FutureProvider<List<Session>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.sessions)..orderBy([(t) => OrderingTerm.desc(t.startedAt)])).get();
});

class HistoryListScreen extends ConsumerWidget {
  const HistoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(allSessionsProvider);
    final loadCalc = ref.watch(loadCalculatorProvider);
    final rTpace = ref.watch(runningThresholdPaceProvider).valueOrNull;
    final wTpace = ref.watch(walkingThresholdPaceProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('トレーニング履歴'),
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text('まだ記録がありません'));
          }
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              
              return ListTile(
                title: Text(session.templateText),
                subtitle: Text(
                  '${DateFormat('yyyy/MM/dd HH:mm').format(session.startedAt)} • ${session.distanceMainM != null ? '${(session.distanceMainM! / 1000).toStringAsFixed(1)}km' : '-'}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Builder(builder: (context) {
                       final tPace = session.activityType == ActivityType.walking ? wTpace : rTpace;
                       final load = loadCalc.computeSessionRepresentativeLoad(session, thresholdPaceSecPerKm: tPace);
                       return Text('負荷: ${load ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold));
                    }),
                    if (session.paceSecPerKm != null)
                       Text(_formatPace(session.paceSecPerKm!), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                onTap: () => context.push('/session/${session.id}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
      ),
    );
  }

  String _formatPace(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}/km';
  }
}
