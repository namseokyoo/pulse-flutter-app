import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String name;
  final String? profileImageUrl;
  final DateTime createdAt;
  final List<String> pulseIds; // 작성한 펄스 ID 목록
  final List<String> bookmarkedPulseIds; // 북마크한 펄스 ID 목록
  final int reputation; // 평판 점수

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    this.profileImageUrl,
    required this.createdAt,
    this.pulseIds = const [],
    this.bookmarkedPulseIds = const [],
    this.reputation = 0,
  });

  // 새 사용자 생성 팩토리 메서드
  factory User.create({
    required String username,
    required String email,
    required String name,
    String? profileImageUrl,
  }) {
    return User(
      id: const Uuid().v4(),
      username: username,
      email: email,
      name: name,
      profileImageUrl: profileImageUrl,
      createdAt: DateTime.now(),
    );
  }

  // 복사본 생성 (필드 업데이트용)
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? name,
    String? profileImageUrl,
    DateTime? createdAt,
    List<String>? pulseIds,
    List<String>? bookmarkedPulseIds,
    int? reputation,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      pulseIds: pulseIds ?? this.pulseIds,
      bookmarkedPulseIds: bookmarkedPulseIds ?? this.bookmarkedPulseIds,
      reputation: reputation ?? this.reputation,
    );
  }

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'pulseIds': pulseIds,
      'bookmarkedPulseIds': bookmarkedPulseIds,
      'reputation': reputation,
    };
  }

  // JSON에서 객체 생성
  factory User.fromJson(Map<String, dynamic> json) {
    // ID 필드 확인
    final id = json['id'] as String? ?? '';

    // 날짜 필드 처리
    DateTime createdAt;
    final createdAtValue = json['createdAt'];

    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      createdAt = DateTime.parse(createdAtValue);
    } else {
      createdAt = DateTime.now(); // 기본값
    }

    // 배열 필드 안전하게 처리
    List<String> pulseIds = [];
    if (json['pulseIds'] != null) {
      if (json['pulseIds'] is List) {
        pulseIds = List<String>.from(
          (json['pulseIds'] as List).map((item) => item.toString()),
        );
      }
    }

    List<String> bookmarkedPulseIds = [];
    if (json['bookmarkedPulseIds'] != null) {
      if (json['bookmarkedPulseIds'] is List) {
        bookmarkedPulseIds = List<String>.from(
          (json['bookmarkedPulseIds'] as List).map((item) => item.toString()),
        );
      }
    }

    return User(
      id: id,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: createdAt,
      pulseIds: pulseIds,
      bookmarkedPulseIds: bookmarkedPulseIds,
      reputation: json['reputation'] as int? ?? 0,
    );
  }
}
