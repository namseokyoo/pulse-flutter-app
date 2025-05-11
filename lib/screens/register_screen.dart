import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../routes.dart';
import '../main.dart'; // AppColors 가져오기

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscureText = true;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
        name: _nameController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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

              // 이름 입력 필드
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '이름',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(
                    Icons.person,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16.0),

              // 사용자 이름 입력 필드
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: '사용자 이름',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(
                    Icons.alternate_email,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '사용자 이름을 입력해주세요';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16.0),

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
                  if (value.length < 6) {
                    return '비밀번호는 최소 6자 이상이어야 합니다';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16.0),

              // 비밀번호 확인 입력 필드
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
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
                obscureText: _obscureText,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 다시 입력해주세요';
                  }
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다';
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

              // 회원가입 버튼
              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
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
                            '회원가입',
                            style: TextStyle(fontSize: 16.0),
                          ),
                ),
              ),

              const SizedBox(height: 16.0),

              // 구분선과 소셜 회원가입 텍스트
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '소셜 계정으로 가입',
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

              // Google 회원가입 버튼
              OutlinedButton.icon(
                onPressed: () async {
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
                        if (e.toString().contains(
                          'firebase_auth/invalid-credential',
                        )) {
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
                },
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
                label: Text(
                  'Google로 계속하기',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
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

              const SizedBox(height: 16.0),

              // 로그인 페이지로 이동 링크
              TextButton(
                onPressed: () {
                  Routes.goBack();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: const Text('이미 계정이 있으신가요? 로그인'),
              ),
            ],
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
