import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/db/app_database.dart';
import '../../core/db/db_providers.dart';
import '../../core/domain/enums.dart';
import '../../core/repos/session_repository.dart';
import '../calendar/calendar_providers.dart';
import '../../core/services/service_providers.dart'; // loadCalculatorProviderのため
import '../settings/advanced_settings_screen.dart';

// allSessionsProvider は db_providers.dart に移動しました

class HistoryListScreen extends ConsumerWidget {
  const HistoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(allSessionsProvider);
    final loadCalc = ref.watch(loadCalculatorProvider);
    final rTpace = ref.watch(runningThresholdPaceProvider).valueOrNull;
    final wTpace = ref.watch(walkingThresholdPaceProvider).valueOrNull;
    final loadMode = ref.watch(loadCalculationModeProvider);

    return Scaffold(
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        title: const Text('トレーニング履歴'),
        leading: const BackButton(),
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
                  '${DateFormat('yyyy/MM/dd').format(session.startedAt)} • ${session.distanceMainM != null ? '${(session.distanceMainM! / 1000).toStringAsFixed(1)}km' : '-'}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Builder(builder: (context) {
                       final tPace = session.activityType == ActivityType.walking ? wTpace : rTpace;
                        final load = loadCalc.computeSessionRepresentativeLoad(
                          session,
                          thresholdPaceSecPerKm: tPace,
                          mode: loadMode,
                        );
                        final displayLoad = load?.toDouble() ?? session.load ?? 0;
                        return Text('負荷: ${displayLoad.round()}', style: const TextStyle(fontWeight: FontWeight.bold));
                    }),
                    if (session.paceSecPerKm != null)
                       Text(_formatPace(session.paceSecPerKm!), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                onTap: () => _showSessionDetail(context, session),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
      ),
    );
  }

  void _showSessionDetail(BuildContext context, Session session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session.templateText),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailItem('日付', DateFormat('yyyy/MM/dd').format(session.startedAt)),
              _detailItem('種目', session.activityType.label),
              if (session.distanceMainM != null)
                _detailItem('距離', '${(session.distanceMainM! / 1000).toStringAsFixed(2)} km'),
              if (session.paceSecPerKm != null)
                _detailItem('ペース', _formatPace(session.paceSecPerKm!)),
              if (session.zone != null)
                _detailItem('ゾーン', session.zone!.name),
              if (session.load != null)
                _detailItem('負荷', session.load!.round().toString()),
              if (session.rpeValue != null)
                _detailItem('RPE (主観的強度)', '${session.rpeValue} / 10'),
              if (session.note != null && session.note!.isNotEmpty)
                _detailItem('メモ', session.note!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/session/${session.id}');
            },
            child: const Text('編集'),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  String _formatPace(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}/km';
  }
}
