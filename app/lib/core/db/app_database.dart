import 'package:drift/drift.dart';

import '../domain/enums.dart';
import 'open_connection.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: <Type>[PersonalBests, Plans, Sessions, MenuPresets, DailyPlanMemos, TargetRaces])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 8;

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
          if (from < 6) {
            // Version 6: Sessions に load カラム追加
            try {
              await m.addColumn(sessions, sessions.load);
            } catch (_) {
              // カラムがすでに存在する場合は無視
            }
          }
          if (from < 7) {
            // Version 7: TargetRaces テーブル作成
            await m.createTable(targetRaces);
          }
          if (from < 8) {
            // Version 8: TargetRaces に種目と距離、Sessions に isRace 追加
            await m.addColumn(targetRaces, targetRaces.raceType);
            await m.addColumn(targetRaces, targetRaces.distance);
            await m.addColumn(sessions, sessions.isRace);
          }
        },
        beforeOpen: (details) async {
          if (details.wasCreated) {
            // 初期データがあればここに入れることも可能
          }
        },
      );
}
