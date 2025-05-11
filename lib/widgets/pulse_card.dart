import 'package:flutter/material.dart';
import '../models/pulse.dart';
import '../routes.dart';
import '../main.dart'; // AppColors 클래스 사용을 위한 import

class PulseCard extends StatelessWidget {
  final Pulse pulse;
  final VoidCallback? onRefresh;

  const PulseCard({super.key, required this.pulse, this.onRefresh});

  // 문자열 첫 글자만 대문자로 변환하는 헬퍼 함수
  String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // 펄스의 중요도에 따른 색상과 라벨 반환
  Map<String, dynamic> _getPulseStatusInfo() {
    final remainingHours = pulse.getRemainingTime().inHours;

    if (remainingHours <= 3) {
      return {
        'color': AppColors.critical,
        'label': 'Critical',
        'waveColor': AppColors.critical,
      };
    } else {
      return {
        'color': AppColors.normal,
        'label': 'Normal',
        'waveColor': AppColors.normal,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getPulseStatusInfo();
    final remainingTime = pulse.getRemainingTimeFormatted();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.cardBackground,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Routes.navigateTo(
              Routes.pulseDetail,
              arguments: {'pulseId': pulse.id},
            ).then((_) {
              // 디테일 화면에서 돌아왔을 때 목록 새로고침
              if (onRefresh != null) {
                onRefresh!();
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 펄스 콘텐츠
                Text(
                  pulse.content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // 하단 영역: 남은 시간 및 상태 표시
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 남은 시간
                    Text(
                      remainingTime,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    // 상태 표시 (Normal 또는 Critical)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusInfo['color'],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusInfo['label'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                // 심전도 파형 - 모든 카드에 항상 표시
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 100,
                      height: 30,
                      child: CustomPaint(
                        painter: WavePainter(color: statusInfo['waveColor']),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 심전도 파형을 그리는 CustomPainter
class WavePainter extends CustomPainter {
  final Color color;

  WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

    final Path path = Path();

    // 시작점
    path.moveTo(0, size.height / 2);

    // 기본 파형
    final double segmentWidth = size.width / 10;

    // 첫 번째 파형
    path.lineTo(segmentWidth, size.height / 2);
    path.lineTo(segmentWidth * 2, size.height / 2);

    // 중앙 피크
    path.lineTo(segmentWidth * 3, size.height * 0.8);
    path.lineTo(segmentWidth * 4, size.height * 0.2);
    path.lineTo(segmentWidth * 5, size.height * 0.8);
    path.lineTo(segmentWidth * 6, size.height / 2);

    // 마무리
    path.lineTo(segmentWidth * 10, size.height / 2);

    // 그리기
    canvas.drawPath(path, paint);

    // 글로우 효과
    final Paint glowPaint =
        Paint()
          ..color = color.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
