import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import 'app_database.dart';

final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((ref) {
  final AppDatabase db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final allSessionsProvider = FutureProvider<List<Session>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.sessions)..orderBy([(t) => OrderingTerm.desc(t.startedAt)])).get();
});

