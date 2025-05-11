import 'package:flutter/material.dart';
import 'main.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/pulse_detail_screen.dart';
import 'screens/create_pulse_screen.dart';
import 'screens/liked_pulses_screen.dart';
import 'screens/my_pulses_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/settings_screen.dart';
import 'services/auth_service.dart';

/// 앱 라우트 관리 클래스
class Routes {
  // 라우트 이름 상수
  static const String splash = '/';
  static const String main = '/main';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String createPulse = '/create-pulse';
  static const String pulseDetail = '/pulse-detail';
  static const String likedPulses = '/liked-pulses';
  static const String myPulses = '/my-pulses';
  static const String settings = '/settings';

  // 라우트 생성 함수
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/main':
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/create-pulse':
        return MaterialPageRoute(builder: (_) => const CreatePulseScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case '/pulse-detail':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PulseDetailScreen(pulseId: args['pulseId']),
        );
      case '/liked-pulses':
        final authService = AuthService();
        if (authService.currentUser == null) {
          // 로그인 되어 있지 않은 경우 로그인 화면으로 이동
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(
          builder:
              (_) => LikedPulsesScreen(userId: authService.currentUser!.id),
        );
      case '/my-pulses':
        final authService = AuthService();
        if (authService.currentUser == null) {
          // 로그인 되어 있지 않은 경우 로그인 화면으로 이동
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(
          builder: (_) => MyPulsesScreen(userId: authService.currentUser!.id),
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(child: Text('${settings.name} 경로를 찾을 수 없습니다')),
              ),
        );
    }
  }

  /// 네비게이터 키 (전역 접근용)
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// 라우트 이동 함수 (컨텍스트 없이도 사용 가능)
  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// 이전 화면으로 돌아가기
  static void goBack([dynamic result]) {
    navigatorKey.currentState!.pop(result);
  }

  /// 현재 화면을 대체하여 이동
  static Future<dynamic> replaceWith(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// 모든 화면을 제거하고 새 화면으로 이동
  static Future<dynamic> clearStackAndNavigateTo(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}
