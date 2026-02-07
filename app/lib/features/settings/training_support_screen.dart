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

🟢 **E (Easy)**: 最大酸素摂取量の59-74%。有酸素能力の基礎構築、毛細血管の発達、回復を目的としたジョギング。
🔵 **M (Marathon)**: 75-84%。マラソンレースのペース。脚作りやペース感覚の養成。
🟡 **T (Threshold)**: 88-92%。乳酸閾値（LT）。血中の乳酸が急増する手前の強度で、20-30分持続可能なペース。
🟠 **I (Interval)**: 95-100%。最大酸素摂取量（VO2max）の向上。3-5分程度の反復走。
🔴 **R (Repetition)**: 100%超。ランニングの効率（ランニングエコノミー）とスピード、無酸素運動能力の向上。
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
        Card(
          color: Colors.teal.shade100.withOpacity(0.3),
          child: ExpansionTile(
            leading: const Icon(Icons.fitness_center, color: Colors.teal),
            title: const Text('負荷計算 (Load) の仕組み', style: TextStyle(fontWeight: FontWeight.bold)),
            initiallyExpanded: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('本アプリでは、以下の4つの方式から負荷計算を選択できます。', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 12),
                    _buildFormulaSubSection(
                      '1. オリジナル (推奨)', 
                      '時間(分) × (閾値P / 実際P) × ゾーン係数 × RPE調整',
                      '速度・ゾーン・主観的強度のすべてを統合したバランスの良い指標です。RPEによる調整幅は ±20% です。'
                    ),
                    _buildFormulaSubSection(
                      '2. rTSS風 (ペース由来)', 
                      '時間(分) × (閾値P / 実際P)³ × ゾーン係数',
                      '速度の比を3乗することで、強度の高い練習（スピード練習）を非常に高い負荷として評価します。'
                    ),
                    _buildFormulaSubSection(
                      '3. sRPE (主観的強度)', 
                      'RPE(0-10) × 時間(分)',
                      'シンプルに「きつさ」と「時間」だけで評価します。心拍計がない場合や、自覚的な疲労を重視したい場合に適しています。'
                    ),
                    _buildFormulaSubSection(
                      '4. ゾーン (定数強度)', 
                      'ゾーン係数 × 時間(分)',
                      '走行ペースに関わらず、ゾーン（強度設定）と時間だけで評価します。'
                    ),
                  ],
                ),
              ),
            ],
          ),
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

※ これらの数値は標準的なTSS（オリジナル/rTSS方式）を想定した目安です。sRPEなど他の計算方式を使用する場合、数値のスケールが異なるため、この基準も変動することに注意してください（例: sRPEの場合は -50 〜 -60 が目安になることもあります）。
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

Widget _buildFormulaSubSection(String title, String formula, String description) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            formula,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(description, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    ),
  );
}
