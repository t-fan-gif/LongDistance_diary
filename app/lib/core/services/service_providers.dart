import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/db_providers.dart';
import '../repos/personal_best_repository.dart';
import 'vdot_calculator.dart';
import 'training_pace_service.dart';

final vdotCalculatorProvider = Provider<VdotCalculator>((ref) {
  return VdotCalculator();
});

final personalBestRepositoryProvider = Provider<PersonalBestRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PersonalBestRepository(db);
});

final trainingPaceServiceProvider = Provider<TrainingPaceService>((ref) {
  final vdotCalc = ref.watch(vdotCalculatorProvider);
  final pbRepo = ref.watch(personalBestRepositoryProvider);
  return TrainingPaceService(vdotCalc, pbRepo);
});
