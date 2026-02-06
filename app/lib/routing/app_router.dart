import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/splash/splash_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/day_detail/day_detail_screen.dart';
import '../features/plan_editor/plan_editor_screen.dart';
import '../features/session_editor/session_editor_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/personal_best_settings_page.dart';
import '../features/settings/menu_preset_settings_page.dart';
import '../features/settings/data_settings_page.dart';
import '../features/history/history_list_screen.dart';
import '../features/analysis/analysis_screen.dart';
import '../features/plan_editor/weekly_plan_screen.dart';
import '../features/analysis/summary_history_screen.dart';
import '../features/settings/goal_settings_page.dart';
import '../features/settings/advanced_settings_screen.dart';
import '../features/settings/training_support_screen.dart';
import '../features/settings/target_race_settings_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: <RouteBase>[
    // スプラッシュ画面
    GoRoute(
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),

    // カレンダー（ホーム）
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const CalendarScreen();
      },
    ),

    // 日詳細
    GoRoute(
      path: '/day/:date',
      builder: (BuildContext context, GoRouterState state) {
        final date = state.pathParameters['date']!;
        return DayDetailScreen(dateString: date);
      },
    ),

    // 予定作成・編集（その日の全予定を一括編集）
    GoRoute(
      path: '/plan/edit',
      builder: (BuildContext context, GoRouterState state) {
        final date = state.uri.queryParameters['date']!;
        return PlanEditorScreen(dateString: date);
      },
    ),

    // 週間予定一覧
    GoRoute(
      path: '/plan/weekly',
      builder: (context, state) => const WeeklyPlanScreen(),
    ),

    // 実績作成
    GoRoute(
      path: '/session/new',
      builder: (BuildContext context, GoRouterState state) {
        final q = state.uri.queryParameters;
        return SessionEditorScreen(
          initialDate: q['date'],
          initialMenuName: q['menuName'],
          initialDistance: q['distance'],
          initialPace: q['pace'],
          initialZone: q['zone'],
          initialReps: q['reps'],
          initialNote: q['note'],
          initialActivityType: q['activityType'],
          initialDailyMemo: q['dailyMemo'],
          initialIsRace: q['isRace'] == 'true',
          initialDuration: q['duration'],
        );
      },
    ),

    // 実績編集
    GoRoute(
      path: '/session/:id',
      builder: (BuildContext context, GoRouterState state) {
        final id = state.pathParameters['id']!;
        return SessionEditorScreen(sessionId: id);
      },
    ),

    // 設定
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) {
        return const SettingsScreen();
      },
      routes: [
        GoRoute(
          path: 'pb',
          builder: (context, state) => const PersonalBestSettingsPage(),
        ),
        GoRoute(
          path: 'presets',
          builder: (context, state) => const MenuPresetSettingsPage(),
        ),
        GoRoute(
          path: 'data',
          builder: (context, state) => const DataSettingsPage(),
        ),
        GoRoute(
          path: 'advanced',
          builder: (context, state) => const AdvancedSettingsScreen(),
        ),
        GoRoute(
          path: 'goals',
          builder: (context, state) => const GoalSettingsPage(),
        ),
        GoRoute(
          path: 'goals_history',
          builder: (context, state) => const SummaryHistoryScreen(),
        ),
        GoRoute(
          path: 'target-race',
          builder: (context, state) => const TargetRaceSettingsScreen(),
        ),
      ],
    ),

    // 履歴
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryListScreen(),
    ),

    // 分析
    GoRoute(
      path: '/analysis',
      builder: (context, state) => const AnalysisScreen(),
    ),

    // トレーニングサポート
    GoRoute(
      path: '/training-support',
      builder: (context, state) => const TrainingSupportScreen(),
    ),
  ],
);
