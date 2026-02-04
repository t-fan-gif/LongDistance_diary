import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repos/export_repository.dart';
import '../../core/services/service_providers.dart';
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
      withData: true, // Webでbytesを取得するために必要
    );

    if (result != null) {
      String jsonString;
      
      if (kIsWeb) {
        final bytes = result.files.single.bytes;
        if (bytes == null) return;
        jsonString = utf8.decode(bytes);
      } else {
        final path = result.files.single.path;
        if (path == null) return;
        final file = File(path);
        jsonString = await file.readAsString();
      }
      
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

  /// 予定のみをインポート（PB/セッションは影響なし、ゾーンからペースを自動計算）
  Future<void> executePlansOnly() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result != null) {
      String jsonString;
      
      if (kIsWeb) {
        final bytes = result.files.single.bytes;
        if (bytes == null) return;
        jsonString = utf8.decode(bytes);
      } else {
        final path = result.files.single.path;
        if (path == null) return;
        final file = File(path);
        jsonString = await file.readAsString();
      }
      
      final paceService = _ref.read(trainingPaceServiceProvider);
      await _repo.importPlansOnly(jsonString, paceService);

      // 予定関連のみ無効化（PBやセッションは変わらない）
      _ref.invalidate(monthCalendarDataProvider);
      _ref.invalidate(selectedMonthProvider);
    }
  }
}
