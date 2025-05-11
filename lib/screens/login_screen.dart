import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../routes.dart';
import '../main.dart'; // AppColors 가져오기

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscureText = true;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // 모든 화면을 제거하고 메인 화면으로 이동 (뒤로 가기 방지)
        Routes.clearStackAndNavigateTo(Routes.main);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        Routes.clearStackAndNavigateTo(Routes.main);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Firebase 오류 메시지를 사용자 친화적인 메시지로 변환
          if (e.toString().contains('firebase_auth/invalid-credential')) {
            _errorMessage = '구글 로그인 인증에 실패했습니다. 다시 시도해주세요.';
          } else {
            _errorMessage = '구글 로그인 오류: ${e.toString()}';
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 앱 로고
                Container(
                  margin: const EdgeInsets.only(bottom: 36.0),
                  child: Column(
                    children: [
                      const Text(
                        'pulse',
                        style: TextStyle(
                          color: AppColors.accentRed,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 20,
                        margin: const EdgeInsets.only(top: 4),
                        child: CustomPaint(
                          painter: WavePainter(color: AppColors.accentRed),
                        ),
                      ),
                    ],
                  ),
                ),

                // 이메일 입력 필드
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: '이메일',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(
                      Icons.email,
                      color: AppColors.accentRed,
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: AppColors.accentRed,
                        width: 2.0,
                      ),
                    ),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력해주세요';
                    }
                    if (!value.contains('@')) {
                      return '유효한 이메일 주소를 입력해주세요';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16.0),

                // 비밀번호 입력 필드
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: AppColors.accentRed,
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: AppColors.accentRed,
                        width: 2.0,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.accentRed,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                  obscureText: _obscureText,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    return null;
                  },
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16.0),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 24.0),

                // 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentRed,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.accentRed.withOpacity(
                        0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                            : const Text(
                              '로그인',
                              style: TextStyle(fontSize: 16.0),
                            ),
                  ),
                ),

                const SizedBox(height: 16.0),

                // 구분선과 소셜 로그인 텍스트
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.divider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        '소셜 계정으로 로그인',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.divider)),
                  ],
                ),

                const SizedBox(height: 16.0),

                // Google 로그인 버튼
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Icon(
                      Icons.g_mobiledata,
                      size: 24.0,
                      color:
                          _isLoading
                              ? AppColors.textSecondary
                              : AppColors.accentRed,
                    ),
                  ),
                  label: const Text('Google로 계속하기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    disabledForegroundColor: AppColors.textSecondary,
                    minimumSize: const Size(double.infinity, 50.0),
                    side: BorderSide(
                      color:
                          _isLoading
                              ? AppColors.divider
                              : AppColors.accentRed.withOpacity(0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),

                const SizedBox(height: 24.0),

                // 회원가입 이동 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '계정이 없으신가요?',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Routes.navigateTo(Routes.register);
                      },
                      child: const Text(
                        '회원가입',
                        style: TextStyle(color: AppColors.accentRed),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 파형 그리기 CustomPainter
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
