import '../models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// 인증 관련 서비스 클래스
class AuthService {
  // 싱글턴 패턴 구현
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Firebase 인스턴스
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // 현재 로그인한 사용자
  User? _currentUser;

  // 현재 사용자 getter
  User? get currentUser => _currentUser;

  // 로그인 상태 확인
  bool get isLoggedIn => _currentUser != null;

  // 사용자 상태 스트림
  Stream<User?> get userStream {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        return null;
      }

      // Firestore에서 사용자 정보 가져오기
      try {
        final doc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
          final userData = doc.data()!;

          // createdAt 필드가 Timestamp 또는 String 타입일 수 있음
          DateTime createdAt;
          if (userData['createdAt'] is Timestamp) {
            createdAt = (userData['createdAt'] as Timestamp).toDate();
          } else if (userData['createdAt'] is String) {
            createdAt = DateTime.parse(userData['createdAt']);
          } else {
            createdAt = DateTime.now(); // 기본값
          }

          // pulseIds와 bookmarkedPulseIds가 없을 경우 빈 배열로 처리
          List<String> pulseIds = [];
          List<String> bookmarkedPulseIds = [];

          // 타입 안전하게 변환
          if (userData['pulseIds'] != null) {
            pulseIds = List<String>.from(userData['pulseIds']);
          }

          if (userData['bookmarkedPulseIds'] != null) {
            bookmarkedPulseIds = List<String>.from(
              userData['bookmarkedPulseIds'],
            );
          }

          _currentUser = User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            username: userData['username'] ?? '',
            name: userData['name'] ?? '',
            profileImageUrl: userData['profileImageUrl'],
            createdAt: createdAt,
            pulseIds: pulseIds,
            bookmarkedPulseIds: bookmarkedPulseIds,
          );

          return _currentUser;
        }
      } catch (e) {
        if (kDebugMode) {
          print('사용자 데이터 로드 오류: $e');
        }
      }

      _currentUser = null;
      return null;
    });
  }

  // 로그인 메서드
  Future<void> login({required String email, required String password}) async {
    try {
      if (kDebugMode) {
        print('로그인 시도: $email');
      }

      // Firebase 인증으로 로그인
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('Firebase 로그인 성공: ${userCredential.user?.uid}');
      }

      if (userCredential.user == null) {
        throw Exception('로그인 실패: 사용자 정보를 찾을 수 없습니다');
      }

      // Firestore에서 사용자 정보 가져오기
      if (kDebugMode) {
        print('Firestore에서 사용자 정보 조회 시도');
      }

      final userDoc =
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      if (!userDoc.exists) {
        throw Exception('로그인 실패: 사용자 프로필을 찾을 수 없습니다');
      }

      final userData = userDoc.data()!;

      if (kDebugMode) {
        print('Firestore 사용자 데이터: $userData');
      }

      // 사용자 데이터 유효성 확인
      if (userData['username'] == null || userData['name'] == null) {
        throw Exception('로그인 실패: 사용자 데이터가 올바르지 않습니다');
      }

      // createdAt 필드 처리
      DateTime createdAt;
      if (userData['createdAt'] is Timestamp) {
        createdAt = (userData['createdAt'] as Timestamp).toDate();
      } else if (userData['createdAt'] is String) {
        createdAt = DateTime.parse(userData['createdAt']);
      } else {
        createdAt = DateTime.now(); // 기본값
      }

      // 배열 필드 안전하게 변환
      List<String> pulseIds = [];
      List<String> bookmarkedPulseIds = [];

      if (userData['pulseIds'] != null) {
        pulseIds = List<String>.from(userData['pulseIds']);
      }

      if (userData['bookmarkedPulseIds'] != null) {
        bookmarkedPulseIds = List<String>.from(userData['bookmarkedPulseIds']);
      }

      // User 모델로 변환
      _currentUser = User(
        id: userCredential.user!.uid,
        email: email,
        username: userData['username'],
        name: userData['name'],
        profileImageUrl: userData['profileImageUrl'],
        createdAt: createdAt,
        pulseIds: pulseIds,
        bookmarkedPulseIds: bookmarkedPulseIds,
        reputation: userData['reputation'] ?? 0,
      );

      if (kDebugMode) {
        print('로그인 완료: ${_currentUser?.username}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('로그인 오류: $e');
        print('오류 세부 정보: ${e.runtimeType}, ${e.toString()}');

        if (e is Error) {
          print('스택 트레이스: ${e.stackTrace}');
        }
      }

      if (e.toString().contains('user-not-found')) {
        throw Exception('등록되지 않은 이메일입니다');
      } else if (e.toString().contains('wrong-password')) {
        throw Exception('비밀번호가 올바르지 않습니다');
      } else if (e.toString().contains('invalid-email')) {
        throw Exception('유효하지 않은 이메일 형식입니다');
      } else if (e.toString().contains('user-disabled')) {
        throw Exception('비활성화된 계정입니다');
      } else if (e.toString().contains('too-many-requests')) {
        throw Exception('너무 많은 로그인 시도가 있었습니다. 잠시 후 다시 시도해주세요');
      } else {
        throw Exception('로그인 실패: ${e.toString()}');
      }
    }
  }

  // 회원가입 메서드
  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String name,
  }) async {
    try {
      if (kDebugMode) {
        print('회원가입 시작: $email, $username');
      }

      // 사용자 이름 중복 확인
      final usernameQuery =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: username)
              .get();

      if (usernameQuery.docs.isNotEmpty) {
        throw Exception('이미 사용 중인 사용자 이름입니다');
      }

      // Firebase 인증으로 사용자 생성
      if (kDebugMode) {
        print('Firebase 인증 사용자 생성 시도');
      }

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('Firebase 인증 사용자 생성 완료: ${userCredential.user?.uid}');
      }

      if (userCredential.user == null) {
        throw Exception('회원가입 실패: 사용자 정보를 생성할 수 없습니다');
      }

      // 생성 시간
      final now = DateTime.now();

      // 사용자 데이터 생성
      final userData = {
        'id': userCredential.user!.uid,
        'email': email,
        'username': username,
        'name': name,
        'profileImageUrl': null,
        'createdAt': Timestamp.fromDate(now),
        'pulseIds': <String>[],
        'bookmarkedPulseIds': <String>[],
        'reputation': 0,
      };

      if (kDebugMode) {
        print('Firestore에 사용자 정보 저장 시도');
      }

      // Firestore에 사용자 정보 저장
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      if (kDebugMode) {
        print('Firestore에 사용자 정보 저장 완료');
      }

      // 현재 사용자 정보 업데이트
      _currentUser = User(
        id: userCredential.user!.uid,
        email: email,
        username: username,
        name: name,
        profileImageUrl: null,
        createdAt: now,
        pulseIds: [],
        bookmarkedPulseIds: [],
        reputation: 0,
      );

      if (kDebugMode) {
        print('회원가입 완료: ${_currentUser?.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('회원가입 오류: $e');
        print('오류 세부 정보: ${e.runtimeType}, ${e.toString()}');

        if (e is Error) {
          print('스택 트레이스: ${e.stackTrace}');
        }
      }
      if (e.toString().contains('email-already-in-use')) {
        throw Exception('이미 사용 중인 이메일입니다');
      }
      throw Exception('회원가입 실패: ${e.toString()}');
    }
  }

  // 비밀번호 재설정 메서드
  Future<void> resetPassword({required String email}) async {
    await Future.delayed(const Duration(seconds: 1));

    // 여기서는 데모를 위해 성공 시나리오를 시뮬레이션합니다
    if (kDebugMode) {
      print('비밀번호 재설정 이메일이 $email로 전송되었습니다');
    }
    return;
  }

  // Google 로그인 메서드
  Future<void> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        print('Google 로그인 시작');
      }

      // Google 로그인 과정 시작
      await _googleSignIn.signOut(); // 기존 세션 정리

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google 로그인이 취소되었습니다');
      }

      // Google 인증 정보 획득
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase 인증 정보 생성
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 인증
      try {
        final userCredential = await _firebaseAuth.signInWithCredential(
          credential,
        );
        final firebaseUser = userCredential.user;

        if (firebaseUser == null) {
          throw Exception('Google 로그인 실패: 사용자 정보를 찾을 수 없습니다');
        }

        // Firestore에서 사용자 정보 확인 (기존 회원인지 체크)
        final userDoc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (!userDoc.exists) {
          // 신규 회원일 경우 Firestore에 정보 저장
          final now = DateTime.now();

          // Google에서 기본 사용자 정보 가져오기
          String userName = 'user_${firebaseUser.uid.substring(0, 5)}';
          String name = '사용자';
          String? photoUrl;

          // Firebase User 정보 사용
          if (firebaseUser.displayName != null &&
              firebaseUser.displayName!.isNotEmpty) {
            userName = firebaseUser.displayName!;
            name = firebaseUser.displayName!;
          }
          // Google User 정보 사용 (백업)
          else if (googleUser.displayName != null &&
              googleUser.displayName!.isNotEmpty) {
            userName = googleUser.displayName!;
            name = googleUser.displayName!;
          }

          // 프로필 이미지 처리
          photoUrl = firebaseUser.photoURL ?? googleUser.photoUrl;

          final userData = {
            'id': firebaseUser.uid,
            'email': firebaseUser.email ?? '',
            'username': userName,
            'name': name,
            'profileImageUrl': photoUrl,
            'createdAt': Timestamp.fromDate(now),
            'pulseIds': <String>[],
            'bookmarkedPulseIds': <String>[],
            'reputation': 0,
          };

          await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .set(userData);

          if (kDebugMode) {
            print('Google 로그인 신규 사용자 정보 저장 완료');
          }

          // 현재 사용자 정보 설정
          _currentUser = User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            username: userData['username'] as String,
            name: userData['name'] as String,
            profileImageUrl: photoUrl,
            createdAt: now,
            pulseIds: [],
            bookmarkedPulseIds: [],
            reputation: 0,
          );
        } else {
          // 기존 회원일 경우 Firestore에서 데이터 가져오기
          final userData = userDoc.data()!;

          // createdAt 필드 처리
          DateTime createdAt;
          if (userData['createdAt'] is Timestamp) {
            createdAt = (userData['createdAt'] as Timestamp).toDate();
          } else if (userData['createdAt'] is String) {
            createdAt = DateTime.parse(userData['createdAt']);
          } else {
            createdAt = DateTime.now(); // 기본값
          }

          // 배열 필드 안전하게 변환
          List<String> pulseIds = [];
          List<String> bookmarkedPulseIds = [];

          if (userData['pulseIds'] != null) {
            pulseIds = List<String>.from(userData['pulseIds']);
          }

          if (userData['bookmarkedPulseIds'] != null) {
            bookmarkedPulseIds = List<String>.from(
              userData['bookmarkedPulseIds'],
            );
          }

          // 프로필 이미지 처리
          String? profileImageUrl = firebaseUser.photoURL;
          if (profileImageUrl == null || profileImageUrl.isEmpty) {
            profileImageUrl =
                googleUser.photoUrl ?? userData['profileImageUrl'] as String?;
          }

          // 사용자 정보 설정
          _currentUser = User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            username: userData['username'] as String,
            name: userData['name'] as String,
            profileImageUrl: profileImageUrl,
            createdAt: createdAt,
            pulseIds: pulseIds,
            bookmarkedPulseIds: bookmarkedPulseIds,
            reputation: userData['reputation'] ?? 0,
          );

          if (kDebugMode) {
            print('Google 로그인 기존 사용자 정보 로드 완료');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Firebase 인증 오류: $e');
        }

        if (e.toString().contains('invalid-credential')) {
          throw Exception('구글 계정 인증에 실패했습니다. 다른 계정으로 시도해보세요.');
        } else {
          throw Exception('Firebase 인증 오류: ${e.toString()}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Google 로그인 오류: $e');
      }

      if (e is Exception) {
        throw e;
      } else {
        throw Exception('Google 로그인 실패: ${e.toString()}');
      }
    }
  }

  // 로그아웃 메서드
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      _currentUser = null;
    } catch (e) {
      if (kDebugMode) {
        print('로그아웃 오류: $e');
      }
      throw Exception('로그아웃 실패: ${e.toString()}');
    }
  }

  // 프로필 업데이트
  Future<void> updateProfile({
    String? username,
    String? profileImageUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || _currentUser == null) {
        throw Exception('로그인되어 있지 않습니다');
      }

      // 업데이트할 데이터
      final Map<String, dynamic> updates = {};

      if (username != null && username != _currentUser!.username) {
        // 사용자 이름 중복 확인
        final usernameQuery =
            await _firestore
                .collection('users')
                .where('username', isEqualTo: username)
                .get();

        if (usernameQuery.docs.isNotEmpty) {
          throw Exception('이미 사용 중인 사용자 이름입니다');
        }

        updates['username'] = username;
      }

      if (profileImageUrl != null) {
        updates['profileImageUrl'] = profileImageUrl;
      }

      if (updates.isNotEmpty) {
        // Firestore 업데이트
        await _firestore.collection('users').doc(user.uid).update(updates);

        // 현재 사용자 정보 업데이트
        _currentUser = _currentUser!.copyWith(
          username: username ?? _currentUser!.username,
          profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('프로필 업데이트 오류: $e');
      }
      throw Exception('프로필 업데이트 실패: ${e.toString()}');
    }
  }

  // 비밀번호 변경 메서드
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('로그인되어 있지 않습니다');
      }

      // 현재 비밀번호 확인을 위해 재인증
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // 비밀번호 변경
      await user.updatePassword(newPassword);
    } catch (e) {
      if (kDebugMode) {
        print('비밀번호 변경 오류: $e');
      }
      if (e is firebase_auth.FirebaseAuthException) {
        if (e.code == 'wrong-password') {
          throw Exception('현재 비밀번호가 올바르지 않습니다');
        }
      }
      throw Exception('비밀번호 변경 실패: ${e.toString()}');
    }
  }

  // 계정 삭제 메서드
  Future<void> deleteAccount({required String password}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('로그인되어 있지 않습니다');
      }

      // 재인증
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Firestore에서 사용자 데이터 삭제
      await _firestore.collection('users').doc(user.uid).delete();

      // Firebase Auth에서 사용자 삭제
      await user.delete();

      _currentUser = null;
    } catch (e) {
      if (kDebugMode) {
        print('계정 삭제 오류: $e');
      }
      if (e is firebase_auth.FirebaseAuthException) {
        if (e.code == 'wrong-password') {
          throw Exception('비밀번호가 올바르지 않습니다');
        }
      }
      throw Exception('계정 삭제 실패: ${e.toString()}');
    }
  }

  // Mock 사용자 로드 (개발 환경 전용)
  void loadMockUsers() {
    if (kDebugMode) {
      print('개발용 Mock 사용자 데이터 로드');
    }

    // Firebase 연동 후에는 이 메서드 사용 중단
  }
}
