import 'package:drift/drift.dart';

import '../domain/enums.dart';
import 'open_connection.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: <Type>[PersonalBests, Plans, Sessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 2;
}
