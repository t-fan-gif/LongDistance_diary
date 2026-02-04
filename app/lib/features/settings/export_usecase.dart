import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/db_providers.dart';
import '../../core/repos/export_repository.dart';
import '../../core/utils/file_helper.dart';

final exportRepositoryProvider = Provider<ExportRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ExportRepository(db);
});

final exportUseCaseProvider = Provider<ExportUseCase>((ref) {
  final repo = ref.watch(exportRepositoryProvider);
  return ExportUseCase(repo);
});

class ExportUseCase {
  ExportUseCase(this._repo);

  final ExportRepository _repo;

  /// データをエクスポートして共有シートを表示する（Webではダウンロード）
  Future<void> execute() async {
    // JSONデータ生成
    final jsonString = await _repo.exportToJson();

    // ファイル名生成
    final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.json';

    // プラットフォームに応じた保存・共有処理
    await FileHelper.saveAndShare(jsonString, fileName);
  }

  /// 予定のみをエクスポート（日付範囲指定）
  Future<void> executePlansOnly(DateTime startDate, DateTime endDate) async {
    final jsonString = await _repo.exportPlansOnly(startDate, endDate);
    final startStr = '${startDate.month}_${startDate.day}';
    final endStr = '${endDate.month}_${endDate.day}';
    final fileName = 'plans_${startStr}_to_${endStr}.json';
    await FileHelper.saveAndShare(jsonString, fileName);
  }
}
