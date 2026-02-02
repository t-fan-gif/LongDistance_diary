import 'package:drift/drift.dart';

import '../domain/enums.dart';
import 'open_connection.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: <Type>[PersonalBests, Plans, Sessions, MenuPresets, DailyPlanMemos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Version 2: Plans テーブルの構造化データ追加（既に反映済み想定だが本来はここに書く）
            // 実際には既に反映されているため、ここでは 2から3への変更を主に見る
          }
          if (from < 3) {
            // Version 3: MenuPresets テーブル作成
            await m.createTable(menuPresets);
          }
          if (from < 4) {
            // Version 4: ActivityType カラムの追加
            await m.addColumn(personalBests, personalBests.activityType);
            await m.addColumn(plans, plans.activityType);
            await m.addColumn(sessions, sessions.activityType);
          }
          if (from < 5) {
            // Version 5: DailyPlanMemos テーブル作成
            await m.createTable(dailyPlanMemos);
          }
        },
        beforeOpen: (details) async {
          if (details.wasCreated) {
            // 初期データがあればここに入れることも可能
          }
        },
      );
}
