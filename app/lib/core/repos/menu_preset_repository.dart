import '../db/app_database.dart';

class MenuPresetRepository {
  final AppDatabase _db;

  MenuPresetRepository(this._db);

  Future<List<MenuPreset>> listPresets() async {
    return _db.select(_db.menuPresets).get();
  }

  Future<void> createPreset(String name) async {
    await _db.into(_db.menuPresets).insert(
          MenuPresetsCompanion.insert(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
          ),
        );
  }

  Future<void> deletePreset(String id) async {
    await (_db.delete(_db.menuPresets)..where((t) => t.id.equals(id))).go();
  }
}
