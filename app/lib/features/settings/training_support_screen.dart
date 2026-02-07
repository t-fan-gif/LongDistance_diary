import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/domain/enums.dart';

class TrainingSupportScreen extends StatelessWidget {
  const TrainingSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('トレーニング計画サポート'),
          leading: const BackButton(),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '基本 (VDOT/ゾーン)'),
              Tab(text: 'パフォーマンス予測'),
              Tab(text: '負荷推定 (CTL/ATL)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _BasicsTab(),
            _PredictionTab(),
            _LoadAnalysisTab(),
          ],
        ),
      ),
    );
  }
}

class _BasicsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
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
''',
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          title: 'ゾーントレーニングとは',
          icon: Icons.favorite,
          content: '''
運動強度を5つのゾーンに分けて管理する方法です。

🟢 **E (Easy)**: 有酸素能力の基礎構築、回復
🔵 **M (Marathon)**: マラソンペースの本番練習
🟡 **T (Threshold)**: 乳酸閾値（LT）の向上
🟠 **I (Interval)**: 最大酸素摂取量（VO2max）の向上
🔴 **R (Repetition)**: スピードと無酸素運動能力
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
          child: const ListTile(
            leading: Icon(Icons.open_in_new, color: Colors.blueGrey),
            title: Text('VDOT計算機（外部サイト）'),
            subtitle: Text('vdoto2.com/calculator'),
          ),
        ),
      ],
    );
  }
}

class _PredictionTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          context,
          title: 'パフォーマンス予測の仕組み',
          icon: Icons.trending_up,
          content: '''
本アプリでは、入力された「自己ベスト」または「直近の練習実績」から将来のレース記録を予測します。

**1. 自己ベストからの予測**
現在登録されている自己ベストの中から、最も高いVDOT値を基準にします。
ジャック・ダニエルズのテーブルに基づき、5kmからフルマラソンまでの予想タイムを算出します。

**2. 練習実績からの推定 (試験実装中)**
直近30日間のセッションのうち、強度が高い（Zone T以上、またはRPEが高い）データのペースと時間から、現在の推定VDOTを逆算します。
「今の走力でレースに出たらどのくらいで走れるか」の目安となります。
''',
        ),
      ],
    );
  }
}

class _LoadAnalysisTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          context,
          title: 'トレーニング負荷 (Load)',
          icon: Icons.fitness_center,
          content: '''
トレーニング負荷は「運動時間 × 強度」で算出されます。

**計算式 (ハイブリッド方式):**
`負荷 = 時間(分) × (閾値ペース/実際のペース)⁴ × ゾーン係数`

強度を4乗することで、ジョグとポイント練習の負荷の差を明確に評価します。
(例: Zone Eで60分 ≒ 60ポイント)
''',
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          title: 'CTL / ATL / TSB とは',
          icon: Icons.analytics,
          content: '''
「分析」タブのグラフで表示される指標です。

**🔵 CTL (Chronic Training Load)**
長期トレーニング負荷（過去42日間の平均）。
あなたの「体力・走力」の積み上げを表します。

**🔴 ATL (Acute Training Load)**
短期トレーニング負荷（過去7日間の平均）。
現在の「疲労」の度合いを表します。

**📈 TSB (Training Stress Balance)**
`TSB = CTL - ATL`
あなたの「コンディション」を表します。
- **+5 〜 -20**: 最適なトレーニングゾーン
- **-20以下**: オーバーワークの危険あり
- **正の数値**: テーパリング（調整）が完了し、レースに向けた「キレ」がある状態
''',
        ),
      ],
    );
  }
}

Widget _buildSection(BuildContext context, {required String title, required IconData icon, required String content}) {
  return Card(
    child: ExpansionTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      initiallyExpanded: true,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(content, style: const TextStyle(height: 1.6)),
        ),
      ],
    ),
  );
}
