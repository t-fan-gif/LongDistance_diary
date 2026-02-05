import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'goal_providers.dart';

class GoalSettingsPage extends ConsumerWidget {
  const GoalSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('走行距離目標'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '目標設定',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DistanceGoalInput(
                    label: '月間走行距離目標',
                    value: ref.watch(monthlyDistanceGoalProvider),
                    onChanged: (val) => ref.read(monthlyDistanceGoalProvider.notifier).setGoal(val),
                  ),
                  const Divider(height: 32),
                  _DistanceGoalInput(
                    label: '週間走行距離目標',
                    value: ref.watch(weeklyDistanceGoalProvider),
                    onChanged: (val) => ref.read(weeklyDistanceGoalProvider.notifier).setGoal(val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '※ 設定した目標は分析画面のサマリー等で進捗確認に使用されます。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistanceGoalInput extends StatelessWidget {
  const _DistanceGoalInput({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        SizedBox(
          width: 80,
          child: TextFormField(
            key: ValueKey(value), // 値が変わった時に再描画を確実にするため
            initialValue: value.toInt().toString(),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.end,
            decoration: const InputDecoration(
              suffixText: ' km',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (val) {
              final d = double.tryParse(val);
              if (d != null) onChanged(d);
            },
          ),
        ),
      ],
    );
  }
}
