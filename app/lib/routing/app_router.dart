import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/calendar/calendar_screen.dart';
import '../features/day_detail/day_detail_screen.dart';
import '../features/plan_editor/plan_editor_screen.dart';
import '../features/session_editor/session_editor_screen.dart';
import '../features/settings/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
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
    ),
  ],
);
