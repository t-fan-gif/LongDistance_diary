import 'package:drift/drift.dart';

import '../domain/enums.dart';
import 'open_connection.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: <Type>[PersonalBests, Plans, Sessions, MenuPresets, DailyPlanMemos, TargetRaces])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 3) {
            await m.createTable(menuPresets);
          }
          if (from < 4) {
            await m.addColumn(personalBests, personalBests.activityType);
            await m.addColumn(plans, plans.activityType);
            await m.addColumn(sessions, sessions.activityType);
          }
          if (from < 5) {
            await m.createTable(dailyPlanMemos);
          }
          if (from < 6) {
            try {
              await m.addColumn(sessions, sessions.load);
            } catch (_) {}
          }
          if (from < 7) {
            await m.createTable(targetRaces);
          }
          if (from < 8) {
            await m.addColumn(targetRaces, targetRaces.raceType);
            await m.addColumn(targetRaces, targetRaces.distance);
            await m.addColumn(sessions, sessions.isRace);
          }
          if (from < 9) {
            await m.addColumn(plans, plans.isRace);
          }
        },
        beforeOpen: (details) async {
          if (details.wasCreated) {
            // 初期データがあればここに入れることも可能
          }
        },
      );
}
