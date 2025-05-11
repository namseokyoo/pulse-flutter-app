import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import '../routes.dart';
import '../main.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 설정
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 페이드인 애니메이션
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    // 펄스 애니메이션 (심장박동 효과)
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.linear),
      ),
    );

    // 애니메이션 시작
    _animationController.repeat();

    // 3초 후 메인 화면으로 이동
    Timer(const Duration(seconds: 3), () {
      Routes.replaceWith(Routes.main);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.background.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고 및 애니메이션
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 앱 타이틀
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'P',
                                style: TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              TextSpan(
                                text: 'ulse',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 심전도 파형
                        Container(
                          width: 200,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CustomPaint(
                            painter: HeartbeatPainter(
                              color: AppColors.primaryBlue,
                              progress: _animationController.value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // 로딩 인디케이터
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),

                // const SizedBox(height: 30),

                // 앱 슬로건
                // const Text(
                //   '순간의 진정성',
                //   style: TextStyle(
                //     fontSize: 18,
                //     color: AppColors.textSecondary,
                //     letterSpacing: 3.0,
                //     fontWeight: FontWeight.w300,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HeartbeatPainter extends CustomPainter {
  final Color color;
  final double progress;

  HeartbeatPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;

    // 글로우 효과
    final Paint glowPaint =
        Paint()
          ..color = color.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);

    final double width = size.width;
    final double height = size.height;

    final Path path = Path();
    final Path animatedPath = Path();

    // 향상된 심전도 파형 패스 설정
    path.moveTo(0, height / 2);
    path.lineTo(width * 0.05, height / 2);
    path.lineTo(width * 0.1, height / 2);
    path.lineTo(width * 0.2, height * 0.4);
    path.lineTo(width * 0.3, height * 0.6);
    path.lineTo(width * 0.4, height / 2);
    path.lineTo(width * 0.45, height / 2);

    // 확장된 심박동 피크
    path.lineTo(width * 0.5, height * 0.1); // 높은 피크
    path.lineTo(width * 0.52, height * 0.9); // 낮은 골
    path.lineTo(width * 0.55, height * 0.3); // 작은 피크
    path.lineTo(width * 0.6, height / 2);

    path.lineTo(width * 0.7, height / 2);
    path.lineTo(width * 0.8, height * 0.4);
    path.lineTo(width * 0.9, height / 2);
    path.lineTo(width, height / 2);

    // 진행 정도에 따라 패스 애니메이션
    final ui.PathMetrics pathMetrics = path.computeMetrics();
    final ui.PathMetric pathMetric = pathMetrics.first;

    // 애니메이션 효과를 부드럽게 하기 위해 진행 정도 조정
    final double normalizedProgress = progress * 1.1; // 약간 더 길게 그려서 부드럽게 연결
    final double effectiveProgress = math.min(1.0, normalizedProgress);
    final double animatedLength = pathMetric.length * effectiveProgress;

    if (animatedLength > 0) {
      animatedPath.addPath(
        pathMetric.extractPath(0, animatedLength),
        Offset.zero,
      );
    }

    // 애니메이션된 경로 그리기 (글로우 효과 먼저, 그 위에 주 경로)
    canvas.drawPath(animatedPath, glowPaint);
    canvas.drawPath(animatedPath, paint);
  }

  @override
  bool shouldRepaint(covariant HeartbeatPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
