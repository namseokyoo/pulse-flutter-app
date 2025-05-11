import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/pulse_service.dart';
import '../routes.dart';
import '../main.dart'; // AppColors 클래스 사용을 위한 import

class CreatePulseScreen extends StatefulWidget {
  const CreatePulseScreen({super.key});

  @override
  State<CreatePulseScreen> createState() => _CreatePulseScreenState();
}

class _CreatePulseScreenState extends State<CreatePulseScreen> {
  final TextEditingController _contentController = TextEditingController();
  final PulseService _pulseService = PulseService();
  bool _isSubmitting = false;
  Duration _pulseDuration = const Duration(hours: 24); // 기본값 24시간

  // 이미지 관련
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _incrementDuration() {
    setState(() {
      // 최대 48시간으로 제한
      if (_pulseDuration.inHours < 48) {
        _pulseDuration = Duration(hours: _pulseDuration.inHours + 1);
      }
    });
  }

  void _decrementDuration() {
    setState(() {
      // 최소 1시간으로 제한
      if (_pulseDuration.inHours > 1) {
        _pulseDuration = Duration(hours: _pulseDuration.inHours - 1);
      }
    });
  }

  void _savePulse() {
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('내용을 입력해주세요'),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 이미지 URL (실제 구현에서는 이미지 업로드 후 URL 획득)
      String? imageUrl;
      if (_imageFile != null) {
        // TODO: 실제 이미지 업로드 구현
        imageUrl = 'https://picsum.photos/200'; // 임시 URL
      }

      _pulseService.createPulse(
        title: content.split('\n').first, // 첫 줄을 제목으로 사용
        content: content,
        author: '사용자', // 실제 사용자 정보로 대체 가능
        imageUrl: imageUrl,
        duration: _pulseDuration,
      );

      Routes.goBack(true); // true는 변경이 있었음을 나타냄
    } catch (e) {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: $e'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String _formatDuration() {
    final hours = _pulseDuration.inHours;
    final minutes = _pulseDuration.inMinutes % 60;
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pulse',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 에디터
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Write your Pulse here...',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 18,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 지속 시간 설정
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Remaining time:',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                ),

                Row(
                  children: [
                    Text(
                      _formatDuration(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Decrement button
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.remove,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: _decrementDuration,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Increment button
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: _incrementDuration,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 심전도 파형 디자인 요소
          SizedBox(
            width: double.infinity,
            height: 80,
            child: Center(
              child: SizedBox(
                width: 200,
                height: 60,
                child: CustomPaint(
                  painter: WavePainter(color: AppColors.primaryBlue),
                ),
              ),
            ),
          ),

          // Post button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: !_isSubmitting ? _savePulse : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child:
                    _isSubmitting
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'Post Pulse',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ),
        ],
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
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;

    final Path path = Path();

    // 시작점
    path.moveTo(0, size.height / 2);

    // 기본 파형
    final double segmentWidth = size.width / 20;

    // 첫 번째 파형 (좌측)
    path.lineTo(segmentWidth * 2, size.height / 2);
    path.lineTo(segmentWidth * 3, size.height * 0.4);
    path.lineTo(segmentWidth * 4, size.height * 0.6);
    path.lineTo(segmentWidth * 5, size.height / 2);

    // 중앙 피크
    path.lineTo(segmentWidth * 7, size.height / 2);
    path.lineTo(segmentWidth * 9, size.height * 0.1);
    path.lineTo(segmentWidth * 11, size.height * 0.9);
    path.lineTo(segmentWidth * 13, size.height / 2);

    // 마지막 부분 (우측)
    path.lineTo(segmentWidth * 15, size.height / 2);
    path.lineTo(segmentWidth * 16, size.height * 0.4);
    path.lineTo(segmentWidth * 17, size.height * 0.6);
    path.lineTo(segmentWidth * 18, size.height / 2);
    path.lineTo(segmentWidth * 20, size.height / 2);

    // 그리기
    canvas.drawPath(path, paint);

    // 글로우 효과
    final Paint glowPaint =
        Paint()
          ..color = color.withOpacity(0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
