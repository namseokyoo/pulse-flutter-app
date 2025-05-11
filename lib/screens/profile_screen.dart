import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/pulse_service.dart';
import 'my_pulses_screen.dart';
import 'liked_pulses_screen.dart';
import 'account_security_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import '../routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final PulseService _pulseService = PulseService();
  bool _isLoading = false;
  int _interactedPulsesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInteractedPulsesCount();
  }

  // 사용자가 상호작용한 펄스 수 가져오기
  Future<void> _loadInteractedPulsesCount() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final allPulses = await _pulseService.getAllPulses();
      final interactedPulses =
          allPulses.where((pulse) {
            return pulse.upvotes.contains(user.id) ||
                pulse.downvotes.contains(user.id);
          }).toList();

      if (mounted) {
        setState(() {
          _interactedPulsesCount = interactedPulses.length;
        });
      }
    } catch (e) {
      debugPrint('상호작용한 펄스 로드 오류: $e');
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.logout();
      if (mounted) {
        // 모든 화면을 제거하고 메인 화면으로 이동
        Routes.clearStackAndNavigateTo(Routes.main);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('로그아웃 실패: ${e.toString()}')));
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
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body:
          user == null
              ? const Center(child: Text('로그인이 필요합니다'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 프로필 헤더
                    Center(
                      child: Column(
                        children: [
                          // 프로필 이미지
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage:
                                user.profileImageUrl != null
                                    ? NetworkImage(user.profileImageUrl!)
                                    : null,
                            child:
                                user.profileImageUrl == null
                                    ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    )
                                    : null,
                          ),
                          const SizedBox(height: 16),

                          // 사용자 이름
                          Text(
                            user.username,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // 이메일
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 가입일
                          Text(
                            '가입일: ${_formatDate(user.createdAt)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // 프로필 메뉴 항목들
                    _buildMenuTile(
                      icon: Icons.edit,
                      title: '프로필 수정',
                      onTap: () {
                        // 프로필 수정 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(user: user),
                          ),
                        ).then((_) {
                          // 프로필 수정 후 상태 갱신
                          setState(() {});
                        });
                      },
                    ),

                    _buildMenuTile(
                      icon: Icons.history,
                      title: '내가 작성한 펄스',
                      subtitle: '${user.pulseIds.length}개',
                      onTap: () {
                        // 내가 작성한 펄스 목록 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MyPulsesScreen(userId: user.id),
                          ),
                        );
                      },
                    ),

                    _buildMenuTile(
                      icon: Icons.thumb_up_alt_outlined,
                      title: '좋아요/싫어요한 펄스',
                      subtitle: '$_interactedPulsesCount개',
                      onTap: () {
                        // 좋아요/싫어요한 펄스 목록 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => LikedPulsesScreen(userId: user.id),
                          ),
                        ).then((_) {
                          // 돌아왔을 때 카운트 다시 로드
                          _loadInteractedPulsesCount();
                        });
                      },
                    ),

                    _buildMenuTile(
                      icon: Icons.security,
                      title: '계정 및 보안',
                      onTap: () {
                        // 계정 및 보안 설정 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountSecurityScreen(),
                          ),
                        );
                      },
                    ),

                    _buildMenuTile(
                      icon: Icons.help_outline,
                      title: '도움말 및 지원',
                      onTap: () {
                        // 도움말 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpSupportScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // 로그아웃 버튼
                    ElevatedButton(
                      onPressed: _isLoading ? null : _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                        foregroundColor: Colors.red.shade700,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('로그아웃'),
                    ),

                    const SizedBox(height: 16),

                    // 계정 삭제 버튼
                    TextButton(
                      onPressed: () {
                        // 계정 삭제 확인 다이얼로그 표시
                        _showDeleteAccountDialog();
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('계정 삭제'),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('계정 삭제'),
            content: const Text(
              '계정을 삭제하시겠습니까? 이 작업은 되돌릴 수 없으며, 모든 데이터가 영구적으로 삭제됩니다.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  // 계정 삭제 로직 구현
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    await _authService.deleteAccount(password: 'password123');

                    if (mounted) {
                      // 삭제 성공 후 메인 화면으로 이동
                      Routes.clearStackAndNavigateTo(Routes.main);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('계정이 성공적으로 삭제되었습니다')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('계정 삭제 실패: ${e.toString()}')),
                    );
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('삭제'),
              ),
            ],
          ),
    );
  }
}
