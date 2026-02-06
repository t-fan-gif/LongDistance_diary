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

    return Scaffold(
      appBar: AppBar(
        title: const Text('トレーニング履歴 (月別)'),
        leading: const BackButton(),
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text('まだ記録がありません'));
          }

          // 月ごとにグループ化
          final Map<String, List<Session>> monthlyGroups = {};
          for (final session in sessions) {
            final key = DateFormat('yyyy-MM').format(session.startedAt);
            if (!monthlyGroups.containsKey(key)) {
              monthlyGroups[key] = [];
            }
            monthlyGroups[key]!.add(session);
          }

          // キーをソート（新しい順）
          final sortedKeys = monthlyGroups.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedKeys.length,
            itemBuilder: (context, index) {
              final key = sortedKeys[index];
              final monthSessions = monthlyGroups[key]!;
              final date = DateTime.parse('$key-01');
              
              // 集計
              double totalDist = 0;
              int count = monthSessions.length;
              for (final s in monthSessions) {
                totalDist += (s.distanceMainM ?? 0) / 1000.0;
              }

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    DateFormat('yyyy年 M月').format(date),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    'Total: ${totalDist.toStringAsFixed(1)} km / $count Sessions',
                    style: const TextStyle(color: Colors.teal),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _MonthlyHistoryScreen(
                          monthDate: date,
                          sessions: monthSessions,
                        ),
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
      ),
    );
  }
}

class _MonthlyHistoryScreen extends StatelessWidget {
  const _MonthlyHistoryScreen({required this.monthDate, required this.sessions});

  final DateTime monthDate;
  final List<Session> sessions;

  @override
  Widget build(BuildContext context) {
    // 週ごとにグループ化
    // 定義: 月曜日始まり
    final Map<String, List<Session>> weeklyGroups = {};
    
    for (final session in sessions) {
        final date = session.startedAt;
        // その週の月曜日
        final monday = DateTime(date.year, date.month, date.day).subtract(Duration(days: date.weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        final key = '${DateFormat('M/d').format(monday)} - ${DateFormat('M/d').format(sunday)}';
        
        if (!weeklyGroups.containsKey(key)) {
          weeklyGroups[key] = [];
        }
        weeklyGroups[key]!.add(session);
    }

    // キーをソート（日付順）
    // 文字列比較だと '10/2' > '10/10' になってしまう可能性があるが、
    // 'M/d' フォーマットなので月またぎ等で注意が必要。
    // 正確にはMondayの日付でソートすべき。
    final sortedKeys = weeklyGroups.keys.toList()..sort((a, b) {
        // "M/d - ..." の最初の部分をパースして比較
        try {
            final aStart = a.split(' - ')[0];
            final bStart = b.split(' - ')[0];
            final aParts = aStart.split('/');
            final bParts = bStart.split('/');
            // 月が小さい方が先、同じなら日が小さい方が先（年は同じと仮定...いや年またぎもありうるがmonthDate内のセッションなので年はほぼ同じ）
            // ただし12月と1月が含まれる場合は？ monthDate基準なので概ね安全。
            final aMonth = int.parse(aParts[0]);
            final aDay = int.parse(aParts[1]);
            final bMonth = int.parse(bParts[0]);
            final bDay = int.parse(bParts[1]);
            
            if (aMonth != bMonth) return bMonth.compareTo(aMonth); // 新しい順にするなら逆
            return bDay.compareTo(aDay); // 新しい順
        } catch (_) {
            return 0;
        }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('${DateFormat('yyyy年M月').format(monthDate)}の履歴'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedKeys.length,
        itemBuilder: (context, index) {
          final key = sortedKeys[index];
          final weekSessions = weeklyGroups[key]!;
          
          double totalDist = 0;
          for (final s in weekSessions) {
             totalDist += (s.distanceMainM ?? 0) / 1000.0;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.calendar_view_week, color: Colors.blueGrey),
              title: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${totalDist.toStringAsFixed(1)} km / ${weekSessions.length} Sessions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _WeeklyHistoryScreen(
                      title: key,
                      sessions: weekSessions,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _WeeklyHistoryScreen extends ConsumerWidget {
  const _WeeklyHistoryScreen({required this.title, required this.sessions});

  final String title;
  final List<Session> sessions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadCalc = ref.watch(loadCalculatorProvider);
    final rTpace = ref.watch(runningThresholdPaceProvider).valueOrNull;
    final wTpace = ref.watch(walkingThresholdPaceProvider).valueOrNull;
    final loadMode = ref.watch(loadCalculationModeProvider);

    // 日付順（新しい順）
    final sortedSessions = List<Session>.from(sessions)..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: sortedSessions.length,
        itemBuilder: (context, index) {
          final session = sortedSessions[index];
          
          return ListTile(
            title: Text(session.templateText),
            subtitle: Builder(
              builder: (context) {
                final dateStr = DateFormat('MM/dd (E)', 'ja').format(session.startedAt);
                final distStr = session.distanceMainM != null ? '${(session.distanceMainM! / 1000).toStringAsFixed(1)}km' : '-';
                
                // 表示ロジック: 実績(Session)のrepsを最優先、なければ予定(Plan)を参照
                String? detailOverride;
                if (session.reps != null && session.distanceMainM != null) {
                  final reps = session.reps!;
                  if (reps > 1) {
                    final perDistM = session.distanceMainM! / reps;
                    final perDistStr = perDistM >= 1000 ? '${(perDistM / 1000).toStringAsFixed(1)}km' : '${perDistM.round()}m';
                    detailOverride = '$perDistStr × $reps';
                  } else if (session.distanceMainM! > 0) {
                     // 1本の場合でも距離が明確なら表示
                     final d = session.distanceMainM!;
                     detailOverride = d >= 1000 ? '${(d / 1000).toStringAsFixed(1)}km' : '${d}m';
                  }
                } else if (session.planId != null) {
                  // 予定からのフォールバック（古いデータ用）
                  final allPlans = ref.watch(allPlansProvider).valueOrNull ?? [];
                  try {
                    final plan = allPlans.firstWhere((p) => p.id == session.planId);
                    if (plan.distance != null) {
                      final pDistM = plan.distance!;
                      final distText = pDistM >= 1000 ? '${(pDistM / 1000).toStringAsFixed(1)}km' : '${pDistM}m';
                      if (plan.reps > 1) {
                        detailOverride = '$distText × ${plan.reps}';
                      } else {
                        detailOverride = distText;
                      }
                    }
                  } catch (_) {}
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$dateStr • $distStr'),
                    if (detailOverride != null)
                      Text(detailOverride, style: const TextStyle(fontSize: 12, color: Colors.teal)),
                  ],
                );
              },
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
              _detailItem('日付', DateFormat('yyyy/MM/dd (E)', 'ja').format(session.startedAt)),
              _detailItem('種目', session.activityType.label),
              if (session.distanceMainM != null)
                _detailItem('距離', '${(session.distanceMainM! / 1000).toStringAsFixed(2)} km'),
              if (session.paceSecPerKm != null)
                _detailItem('ペース', _formatPace(session.paceSecPerKm!)),
              if (session.durationMainSec != null)
                _detailItem('時間', _formatDuration(session.durationMainSec!)), // フォーマット修正
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

  String _formatDuration(int totalSec) { // 追加
    final h = totalSec ~/ 3600;
    final m = (totalSec % 3600) ~/ 60;
    final s = totalSec % 60;
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
