import 'package:drift/drift.dart';

import '../domain/enums.dart';
import 'open_connection.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: <Type>[PersonalBests, Plans, Sessions, MenuPresets, DailyPlanMemos, TargetRaces])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 13;

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
            try {
              await m.addColumn(targetRaces, targetRaces.raceType);
            } catch (_) {}
            try {
              await m.addColumn(targetRaces, targetRaces.distance);
            } catch (_) {}
            try {
              await m.addColumn(sessions, sessions.isRace);
            } catch (_) {}
          }
          if (from < 9) {
            await m.addColumn(plans, plans.isRace);
          }
          if (from < 10) {
            await m.addColumn(plans, plans.duration);
          }
          if (from < 11) {
            await _addColumnIfNotExists(m, plans, plans.reps);
            await _addColumnIfNotExists(m, sessions, sessions.reps);
          }
          if (from < 12) {
             // No op for v12 as it was just a retry bump
          }
          if (from < 13) {
             // No op for v13 as it's just ensuring migration logic runs with the new helper
          }
        },
        beforeOpen: (details) async {
          if (details.wasCreated) {
            // 初期データがあればここに入れることも可能
          }
        },
      );

  Future<void> _addColumnIfNotExists(
      Migrator m, TableInfo table, GeneratedColumn column) async {
    final result =
        await customSelect('PRAGMA table_info(${table.actualTableName})').get();
    final exists = result.any((row) => row.read<String>('name') == column.name);
    if (!exists) {
      await m.addColumn(table, column);
    }
  }
}
