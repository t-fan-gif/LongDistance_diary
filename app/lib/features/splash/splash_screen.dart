import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();

    // 2秒後にメイン画面へ遷移
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景画像
          Image.asset(
            'assets/bar.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0.85, 0.0), // さらに右側（人の部分）に寄せる
          ),
          // オーバーレイグラデーション
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          // コンテンツ
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        'LD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'LONG DISTANCE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 4),
                          blurRadius: 10,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Training Diary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const Spacer(flex: 2),
                  const Text(
                    'LOADING...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4.0,
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
