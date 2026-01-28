import 'package:drift/drift.dart';

import '../domain/enums.dart';

class PersonalBests extends Table {
  TextColumn get id => text()();
  TextColumn get event => textEnum<PbEvent>()();
  IntColumn get timeMs => integer()();
  DateTimeColumn get date => dateTime().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Plans extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get templateText => text()();
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

  IntColumn get repLoad => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
