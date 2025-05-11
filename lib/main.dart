import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/create_pulse_screen.dart';
import 'screens/splash_screen.dart';
import 'services/pulse_service.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'package:flutter/foundation.dart';

void main() async {
  // Flutter 위젯 바인딩 확인
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Firestore에 초기 데이터 설정 (데이터가 없을 경우만)
  try {
    await PulseService().setupInitialData();
    if (kDebugMode) {
      print('Firestore 초기 데이터 설정 완료');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Firestore 초기 데이터 설정 오류: $e');
    }
  }

  // Firebase Auth 초기화 (필요한 경우 더미 사용자 생성)
  try {
    AuthService().loadMockUsers();
  } catch (e) {
    if (kDebugMode) {
      print('Auth 서비스 초기화 오류: $e');
    }
  }

  runApp(const PulseApp());
}

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pulse',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            color: Colors.redAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.redAccent),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CreatePulseScreen(),
    const Center(child: Text('알림')), // 임시 알림 화면
  ];

  void _onTabTapped(int index) {
    // 로그인 여부 확인
    final authService = AuthService();

    // Create 또는 Alerts 탭 클릭 시 로그인 확인
    if ((index == 1 || index == 2) && !authService.isLoggedIn) {
      // 로그인되지 않은 상태라면 로그인 화면으로 이동
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('로그인 필요'),
              content: const Text('이 기능을 사용하려면 로그인이 필요합니다.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // 다이얼로그 닫기
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text('로그인하기'),
                ),
              ],
            ),
      );
      return; // 탭 변경 중단
    }

    // 작성 화면은 매번 새로 생성해야 함
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreatePulseScreen()),
      ).then((result) {
        if (result == true) {
          // 홈 화면으로 돌아가기
          setState(() {
            _currentIndex = 0;
          });
        }
      });
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 80, fit: BoxFit.contain),

        elevation: _currentIndex == 0 ? 0 : 1,
        backgroundColor: Colors.white,
        actions: [
          if (_currentIndex == 0) // 홈 화면일 때만 검색, 프로필 아이콘 표시
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: 검색 기능 구현
              },
            ),
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                // 로그인 여부 확인
                final authService = AuthService();
                if (authService.isLoggedIn) {
                  // 로그인 상태면 프로필 화면으로 이동
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                } else {
                  // 비로그인 상태면 로그인 화면으로 이동
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }
}
