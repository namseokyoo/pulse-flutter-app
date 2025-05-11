import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('도움말 및 지원')),
      body: ListView(
        children: [
          // 자주 묻는 질문 섹션
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '자주 묻는 질문',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          _buildFaqItem(
            context,
            '펄스란 무엇인가요?',
            '펄스는 24시간 동안 유지되는 일시적인 게시물입니다. 사용자들의 좋아요/싫어요에 따라 지속 시간이 변경될 수 있습니다.',
          ),

          _buildFaqItem(
            context,
            '좋아요와 싫어요는 어떻게 작동하나요?',
            '좋아요를 누르면 해당 펄스의 지속 시간이 30분 연장되고, 싫어요를 누르면 30분 줄어듭니다. 단, 최소 1시간은 유지됩니다.',
          ),

          _buildFaqItem(
            context,
            '계정을 삭제하면 내 게시물은 어떻게 되나요?',
            '계정을 삭제하면 모든 개인 데이터와 작성한 게시물이 영구적으로 삭제됩니다.',
          ),

          const Divider(),

          // 문의하기 섹션
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '문의하기',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('이메일 문의'),
            subtitle: const Text('support@pulse-app.com'),
            onTap: () {
              // 이메일 앱 열기 (실제 구현에서는 url_launcher 사용)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('이메일 앱을 여는 기능은 준비 중입니다')),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('라이브 채팅'),
            subtitle: const Text('평일 오전 9시 ~ 오후 6시'),
            onTap: () {
              // 채팅 화면으로 이동
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('라이브 채팅 기능은 준비 중입니다')),
              );
            },
          ),

          const Divider(),

          // 앱 정보 섹션
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '앱 정보',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('앱 버전'),
            subtitle: const Text('1.0.0'),
          ),

          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('이용약관'),
            onTap: () {
              // 이용약관 화면으로 이동
              _showTermsDialog(context, '이용약관', _termsOfServiceText);
            },
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('개인정보 처리방침'),
            onTap: () {
              // 개인정보처리방침 화면으로 이동
              _showTermsDialog(context, '개인정보 처리방침', _privacyPolicyText);
            },
          ),
        ],
      ),
    );
  }

  // 자주 묻는 질문 아이템 위젯
  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: TextStyle(color: Colors.grey.shade700)),
        ),
      ],
    );
  }

  // 이용약관 등 텍스트 보여주는 다이얼로그
  void _showTermsDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(child: Text(content)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  // 이용약관 샘플 텍스트
  static const String _termsOfServiceText = '''
제 1 조 (목적)
이 약관은 Pulse 서비스를 이용함에 있어 필요한 이용자와 Pulse의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.

제 2 조 (정의)
1. "서비스"라 함은 Pulse가 제공하는 모든 서비스를 의미합니다.
2. "이용자"라 함은 이 약관에 동의하고 Pulse가 제공하는 서비스를 이용하는 자를 말합니다.
3. "펄스"라 함은 이용자가 작성한 24시간 동안 유지되는 게시물을 의미합니다.
  ''';

  // 개인정보처리방침 샘플 텍스트
  static const String _privacyPolicyText = '''
1. 개인정보의 수집 및 이용목적
Pulse는 다음의 목적을 위하여 개인정보를 처리합니다. 처리한 개인정보는 다음의 목적 이외의 용도로는 사용되지 않으며, 이용 목적이 변경될 경우에는 개인정보 보호법 제18조에 따라 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다.

- 회원 가입 및 관리
- 서비스 제공
- 마케팅 및 광고에의 활용

2. 개인정보의 처리 및 보유 기간
Pulse는 법령에 따른 개인정보 보유·이용기간 또는 이용자로부터 개인정보를 수집 시에 동의 받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.
  ''';
}
