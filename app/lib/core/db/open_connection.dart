import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Opens a database connection that works on all platforms.
/// - Native platforms (Android, iOS, macOS, Linux, Windows): Uses SQLite
/// - Web: Uses IndexedDB via sql.js
QueryExecutor openConnection() {
  return driftDatabase(
    name: 'long_distance_diary',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
