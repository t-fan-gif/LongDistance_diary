import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 月間走行距離目標を管理するプロバイダ
final monthlyDistanceGoalProvider = StateNotifierProvider<DistanceGoalNotifier, double>(
  (ref) => DistanceGoalNotifier('monthly_distance_goal', 200.0),
);

/// 週間走行距離目標を管理するプロバイダ
final weeklyDistanceGoalProvider = StateNotifierProvider<DistanceGoalNotifier, double>(
  (ref) => DistanceGoalNotifier('weekly_distance_goal', 50.0),
);

class DistanceGoalNotifier extends StateNotifier<double> {
  DistanceGoalNotifier(this.key, this.defaultValue) : super(defaultValue) {
    _loadFromPrefs();
  }

  final String key;
  final double defaultValue;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(key) ?? defaultValue;
  }

  Future<void> setGoal(double goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, goal);
    state = goal;
  }
}
