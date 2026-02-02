import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repos/export_repository.dart';
import '../calendar/calendar_providers.dart';
import 'export_usecase.dart';
import 'settings_screen.dart';

final importUseCaseProvider = Provider<ImportUseCase>((ref) {
  final repo = ref.watch(exportRepositoryProvider);
  return ImportUseCase(repo, ref);
});

class ImportUseCase {
  ImportUseCase(this._repo, this._ref);

  final ExportRepository _repo;
  final Ref _ref;

  /// ファイルを選択してインポートを実行する
  Future<void> execute() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      
      await _repo.importFromJson(jsonString);

      // 全データ無効化
      _ref.invalidate(monthCalendarDataProvider);
      _ref.invalidate(runningThresholdPaceProvider);
      _ref.invalidate(walkingThresholdPaceProvider);
      _ref.invalidate(personalBestsProvider);
      _ref.invalidate(menuPresetsProvider);
      _ref.invalidate(selectedMonthProvider); // カレンダー一式
    }
  }
}
