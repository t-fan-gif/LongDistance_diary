import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/db/db_providers.dart';
import '../../core/repos/export_repository.dart';

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

  /// データをエクスポートして共有シートを表示する
  Future<void> execute() async {
    // JSONデータ生成
    final jsonString = await _repo.exportToJson();

    // 一時ファイルに保存
    final directory = await getTemporaryDirectory();
    final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonString);

    // 共有（XFileを使用）
    final xFile = XFile(file.path, mimeType: 'application/json');
    // ignore: deprecated_member_use
    await Share.shareXFiles([xFile], text: 'Long Distance Diary Backup Data');
  }
}
