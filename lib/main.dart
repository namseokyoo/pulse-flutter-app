import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/create_pulse_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/settings_screen.dart';
import 'services/pulse_service.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'package:flutter/foundation.dart';
import 'routes.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  // Flutter 위젯 바인딩 확인
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 옵션
  final firebaseOptions = DefaultFirebaseOptions.currentPlatform;

  try {
    // Firebase 초기화
    await Firebase.initializeApp(options: firebaseOptions);

    if (kDebugMode) {
      print('Firebase 초기화 완료');
    }

    // 디버그 모드에서 구글 로그인 설정
    if (kDebugMode) {
      // 에뮬레이터에서 웹뷰 인증 사용
      await GoogleSignIn(scopes: ['email', 'profile']).signInSilently();
      print('Google SignIn 초기화 완료');
    }

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
      if (kDebugMode) {
        print('Auth 서비스 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth 서비스 초기화 오류: $e');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Firebase 또는 Google SignIn 초기화 오류: $e');
    }
  }

  runApp(const PulseApp());
}

// 앱의 테마 색상 정의
class AppColors {
  static const Color primaryBlue = Color(0xFFFF5252);
  static const Color primaryBlueLight = Color(0xFFFF7B7B);
  static const Color accentRed = Color(0xFFFF5252);
  static const Color accentBlue = Color(0xFFFF5252);
  static const Color background = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color divider = Color(0xFF323232);
  static const Color critical = Color(0xFFFF5252);
  static const Color normal = Color(0xFFFF5252);
}

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: Routes.navigatorKey,
      title: 'Pulse',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primaryBlue,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryBlue,
          secondary: AppColors.accentBlue,
          surface: AppColors.cardBackground,
          background: AppColors.background,
          error: AppColors.accentRed,
        ),
        cardTheme: const CardTheme(
          color: AppColors.cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
          centerTitle: true,
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.primaryBlue),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.textSecondary,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.primaryBlue;
            }
            return AppColors.textSecondary;
          }),
          trackColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.primaryBlue.withOpacity(0.5);
            }
            return AppColors.textSecondary.withOpacity(0.3);
          }),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
          titleLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(color: AppColors.textPrimary),
          titleSmall: TextStyle(color: AppColors.textSecondary),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primaryBlue,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryBlue,
          secondary: AppColors.accentBlue,
          surface: AppColors.cardBackground,
          background: AppColors.background,
          error: AppColors.accentRed,
        ),
        cardTheme: const CardTheme(
          color: AppColors.cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
          centerTitle: true,
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.primaryBlue),
        ),
      ),
      themeMode: ThemeMode.dark, // 항상 다크 모드 사용
      initialRoute: Routes.splash,
      onGenerateRoute: Routes.generateRoute,
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

  // 화면 목록
  final List<Widget> _screens = [
    const HomeScreen(),
    const CreatePulseScreen(),
    const SettingsScreen(),
  ];

  // 홈 화면 새로고침 함수
  void _refreshHomeScreen() {
    // 싱글톤을 통해 홈 화면 상태에 접근하여 새로고침
    HomeScreenState().refreshData();
  }

  void _onTabTapped(int index) {
    // 로그인 여부 확인
    final authService = AuthService();

    // Create 탭 클릭 시 로그인 확인
    if (index == 1 && !authService.isLoggedIn) {
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
                    Routes.navigateTo(Routes.login);
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
      Routes.navigateTo(Routes.createPulse).then((result) {
        if (result == true) {
          // 홈 화면으로 돌아가고 데이터 새로고침
          setState(() {
            _currentIndex = 0;
          });

          // 홈 화면 데이터 새로고침
          _refreshHomeScreen();

          // 디버그 확인용 로그
          debugPrint('펄스 작성 완료 후 홈 화면 새로고침 요청');
        }
      });
    } else {
      setState(() {
        _currentIndex = index;
      });

      // 홈 화면으로 돌아오면 새로고침
      if (index == 0) {
        _refreshHomeScreen();

        // 디버그 확인용 로그
        debugPrint('홈 탭 선택 - 새로고침 요청');
      }
    }
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
        elevation: 0,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Create Pulse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
