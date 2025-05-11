import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // 비밀번호 변경 관련 상태
  final _passwordFormKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _passwordErrorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 비밀번호 변경 다이얼로그 표시
  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('비밀번호 변경'),
            content: Form(
              key: _passwordFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 현재 비밀번호
                  TextFormField(
                    controller: _currentPasswordController,
                    decoration: const InputDecoration(
                      labelText: '현재 비밀번호',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '현재 비밀번호를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // 새 비밀번호
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(
                      labelText: '새 비밀번호',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '새 비밀번호를 입력해주세요';
                      }
                      if (value.length < 6) {
                        return '비밀번호는 최소 6자 이상이어야 합니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // 새 비밀번호 확인
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: '새 비밀번호 확인',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '새 비밀번호를 다시 입력해주세요';
                      }
                      if (value != _newPasswordController.text) {
                        return '비밀번호가 일치하지 않습니다';
                      }
                      return null;
                    },
                  ),

                  // 에러 메시지
                  if (_passwordErrorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _passwordErrorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: _isLoading ? null : () => _changePassword(context),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('변경'),
              ),
            ],
          ),
    );
  }

  // 비밀번호 변경 처리
  Future<void> _changePassword(BuildContext dialogContext) async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _passwordErrorMessage = null;
    });

    try {
      await _authService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        Navigator.pop(dialogContext); // 다이얼로그 닫기

        // 성공 메시지 표시
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('비밀번호가 성공적으로 변경되었습니다')));

        // 컨트롤러 초기화
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      setState(() {
        _passwordErrorMessage = e.toString();
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
      appBar: AppBar(title: const Text('계정 및 보안')),
      body: ListView(
        children: [
          // 보안 섹션
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('보안', style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          // 비밀번호 변경
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('비밀번호 변경'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showChangePasswordDialog,
          ),

          // 로그인 활동
          const ListTile(
            leading: Icon(Icons.device_unknown),
            title: Text('로그인 활동'),
            subtitle: Text('모든 기기에서 확인'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),

          // 2단계 인증
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('2단계 인증'),
            subtitle: const Text('추가 보안 계층을 위한 설정'),
            trailing: Switch(
              value: false, // 현재 비활성화 상태
              onChanged: (_) {
                // 실제 구현에서는 2단계 인증 설정 화면으로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('이 기능은 아직 개발 중입니다')),
                );
              },
            ),
          ),

          const Divider(),

          // 개인정보 섹션
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('개인정보', style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          // 개인정보 설정
          const ListTile(
            leading: Icon(Icons.visibility),
            title: Text('개인정보 설정'),
            subtitle: Text('프로필 정보 공개 범위 설정'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),

          // 데이터 다운로드
          const ListTile(
            leading: Icon(Icons.download),
            title: Text('내 데이터 다운로드'),
            subtitle: Text('내 계정의 모든 데이터 다운로드'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
    );
  }
}
