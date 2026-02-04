import 'package:drift/drift.dart';

import '../domain/enums.dart';

class PersonalBests extends Table {
  TextColumn get id => text()();
  TextColumn get event => textEnum<PbEvent>()();
  IntColumn get timeMs => integer()();
  DateTimeColumn get date => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get activityType => textEnum<ActivityType>().withDefault(const Constant('running'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Plans extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  
  // メニュー名（旧 templateText）
  TextColumn get menuName => text()();
  
  // 構造化データ
  IntColumn get distance => integer().nullable()(); // m単位
  IntColumn get pace => integer().nullable()();     // 秒/km
  TextColumn get zone => textEnum<Zone>().nullable()();
  IntColumn get reps => integer().withDefault(const Constant(1))();
  TextColumn get activityType => textEnum<ActivityType>().withDefault(const Constant('running'))();
  
  TextColumn get note => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Sessions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startedAt => dateTime().named('date_time')();
  TextColumn get planId => text().nullable().references(Plans, #id)();

  TextColumn get templateText => text()();

  IntColumn get distanceMainM => integer().nullable()();
  IntColumn get durationMainSec => integer().nullable()();
  IntColumn get paceSecPerKm => integer().nullable()();

  TextColumn get zone => textEnum<Zone>().nullable()();
  IntColumn get rpeValue => integer().nullable()();

  TextColumn get restType => textEnum<RestType>().nullable()();
  IntColumn get restDurationSec => integer().nullable()();
  IntColumn get restDistanceM => integer().nullable()();

  IntColumn get wuDistanceM => integer().nullable()();
  IntColumn get wuDurationSec => integer().nullable()();
  IntColumn get cdDistanceM => integer().nullable()();
  IntColumn get cdDurationSec => integer().nullable()();

  TextColumn get status => textEnum<SessionStatus>()();

  TextColumn get note => text().nullable()();
  RealColumn get load => real().nullable()();
  IntColumn get repLoad => integer().nullable()();
  TextColumn get activityType => textEnum<ActivityType>().withDefault(const Constant('running'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MenuPresets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class DailyPlanMemos extends Table {
  DateTimeColumn get date => dateTime()(); // 日付部分のみ使用
  TextColumn get note => text()();

  @override
  Set<Column<Object>> get primaryKey => {date};
}

/// ターゲットレース（メイン/サブ）
class TargetRaces extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();           // レース名
  DateTimeColumn get date => dateTime()();   // レース日
  BoolColumn get isMain => boolean()();      // メインターゲットかどうか
  TextColumn get note => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

