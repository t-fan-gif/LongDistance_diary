import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/db_providers.dart';
import '../repos/personal_best_repository.dart';
import '../repos/session_repository.dart';
import 'vdot_calculator.dart';
import 'training_pace_service.dart';
import 'load_calculator.dart';
import 'analysis_service.dart';

final vdotCalculatorProvider = Provider<VdotCalculator>((ref) {
  return VdotCalculator();
});

final loadCalculatorProvider = Provider<LoadCalculator>((ref) {
  return LoadCalculator();
});

final personalBestRepositoryProvider = Provider<PersonalBestRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PersonalBestRepository(db);
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SessionRepository(db);
});

final trainingPaceServiceProvider = Provider<TrainingPaceService>((ref) {
  final vdotCalc = ref.watch(vdotCalculatorProvider);
  final pbRepo = ref.watch(personalBestRepositoryProvider);
  return TrainingPaceService(vdotCalc, pbRepo);
});

final analysisServiceProvider = Provider<AnalysisService>((ref) {
  final vdotCalc = ref.watch(vdotCalculatorProvider);
  final loadCalc = ref.watch(loadCalculatorProvider);
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  return AnalysisService(vdotCalc, loadCalc, sessionRepo);
});
