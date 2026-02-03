import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LoadCalculationMode {
  priorityPace('ペース優先', 'Pace > sRPE > Zone'),
  onlyPace('ペースのみ', 'Paceのみ計算に使用'),
  onlySrpe('sRPEのみ', 'sRPEのみ計算に使用'),
  onlyZone('ゾーンのみ', 'ゾーンのみ計算に使用');

  final String label;
  final String description;
  const LoadCalculationMode(this.label, this.description);
}

final loadCalculationModeProvider = StateProvider<LoadCalculationMode>((ref) => LoadCalculationMode.priorityPace);

class AdvancedSettingsScreen extends ConsumerWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(loadCalculationModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('詳細設定'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, '負荷計算方式の選択'),
          Card(
            child: Column(
              children: LoadCalculationMode.values.map((mode) {
                return RadioListTile<LoadCalculationMode>(
                  title: Text(mode.label),
                  subtitle: Text(mode.description),
                  value: mode,
                  groupValue: currentMode,
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(loadCalculationModeProvider.notifier).state = val;
                    }
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, '計算式の確認'),
          _buildFormulaCard(
            context,
            '1. ペース由来負荷 (rTSS風)',
            '時間(分) × (閾値ペース / 実際のペース)^3 × 3',
            '走力（閾値ペース）と実際のペースの比率から算出される最も精密な負荷指標です。',
          ),
          _buildFormulaCard(
            context,
            '2. 主観的負荷 (sRPE)',
            'RPE(0-10) × 時間(分)',
            '主観的なキツさと実施時間の掛け合わせで算出される汎用的な負荷指標です。',
          ),
          _buildFormulaCard(
            context,
            '3. ゾーン由来負荷',
            'ゾーン係数 × 時間(分) × 3',
            '設定された心拍/ペースゾーン（E, M, T, I, R）の強度係数から算出されます。',
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '※ 現在、計算の優先順位は [ペース > sRPE > ゾーン] となっています。データが存在する中で最も高い優先順位のものが採用されます。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildFormulaCard(BuildContext context, String title, String formula, String detail) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                formula,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(detail, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
