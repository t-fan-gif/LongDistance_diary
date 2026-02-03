import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TrainingSupportScreen extends StatelessWidget {
  const TrainingSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        title: const Text('トレーニング計画サポート'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'VDOTとは',
            icon: Icons.speed,
            content: '''
VDOTは、ジャック・ダニエルズ博士が開発したランニング能力を表す指標です。

レースの記録から算出され、この数値を基に最適なトレーニングペースを計算できます。

**VDOTの特徴:**
• 5km〜マラソンまで、様々な距離で比較可能
• 数値が大きいほど高いパフォーマンス
• トレーニング強度の設定に活用

**活用方法:**
1. 自己ベストを入力してVDOTを算出
2. 各ゾーンの推奨ペースを確認
3. 計画的なトレーニングを実施
''',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'ゾーントレーニングとは',
            icon: Icons.favorite,
            content: '''
ゾーントレーニングは、運動強度を5つのゾーンに分けて管理する方法です。

**ゾーン一覧:**

🟢 **E (Easy)** - イージー
• 強度: 65-79% HRmax
• 目的: 有酸素能力の基礎構築、回復
• 感覚: 会話しながら走れる

🔵 **M (Marathon)** - マラソンペース
• 強度: 80-85% HRmax
• 目的: マラソン本番ペースの習得
• 感覚: やや速い持続可能なペース

🟡 **T (Threshold)** - 閾値走
• 強度: 86-89% HRmax
• 目的: 乳酸閾値の向上
• 感覚: 快適に速い、20-30分維持可能

🟠 **I (Interval)** - インターバル
• 強度: 94-98% HRmax
• 目的: VO2maxの向上
• 感覚: かなりきつい、3-5分維持

🔴 **R (Repetition)** - レペティション
• 強度: 全力に近い
• 目的: スピードとランニングエコノミー
• 感覚: 非常にきつい、短時間のみ

**週間トレーニング構成の目安:**
• Easy: 70-80%
• Threshold/Interval: 10-20%
• レース/高強度: 5-10%
''',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: '負荷（Load）について',
            icon: Icons.fitness_center,
            content: '''
トレーニング負荷は、運動の量と強度を組み合わせた指標です。

**計算方法:**
本アプリでは3つの方法で負荷を計算できます：

1. **ペース基準 (rTSS)**
   VDOTから算出した閾値ペースを基準に計算

2. **主観的強度 (sRPE)**
   RPE（運動強度の自己評価）× 時間で計算

3. **ゾーン基準**
   トレーニングゾーンごとの重み付けで計算

**負荷管理のポイント:**
• 急激な負荷増加を避ける（週10%以内が目安）
• 高負荷週と低負荷週を交互に
• 疲労の蓄積に注意
''',
          ),
          const SizedBox(height: 32),
          Card(
            color: Colors.teal.shade50,
            child: ListTile(
              leading: const Icon(Icons.timer, color: Colors.teal),
              title: const Text('自己ベストを入力'),
              subtitle: const Text('VDOTとトレーニングペースを算出'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/settings/pb'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.open_in_new, color: Colors.blueGrey),
              title: const Text('VDOT計算機（外部サイト）'),
              subtitle: const Text('vdoto2.com/calculator'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Card(
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        initiallyExpanded: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: const TextStyle(height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
