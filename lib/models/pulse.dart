import 'dart:math' as Math;
import 'package:cloud_firestore/cloud_firestore.dart';

class Pulse {
  final String id;
  final String author;
  final String title;
  final String content;
  final String? imageUrl; // 이미지 URL
  final List<String> tags; // 태그
  final List<String> upvotes; // 좋아요(시간 연장) 사용자 ID 목록
  final List<String> downvotes; // 싫어요(시간 축소) 사용자 ID 목록
  final DateTime createdAt;
  final Duration duration;

  Pulse({
    required this.id,
    required this.author,
    required this.title,
    required this.content,
    this.imageUrl,
    this.tags = const [],
    this.upvotes = const [],
    this.downvotes = const [],
    required this.createdAt,
    this.duration = const Duration(hours: 24),
  });

  // 좋아요 수
  int get upvoteCount => upvotes.length;

  // 싫어요 수
  int get downvoteCount => downvotes.length;

  // 총 투표 수
  int get totalVotes => upvoteCount + downvoteCount;

  String get remainingTime {
    final expiresAt = createdAt.add(duration);
    final remaining = expiresAt.difference(DateTime.now());

    if (remaining.isNegative) {
      return '만료됨';
    }

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    return '$hours시간 $minutes분';
  }

  // 좋아요 추가 (시간 연장)
  Pulse addUpvote(String userId) {
    if (upvotes.contains(userId)) return this;

    // 이미 싫어요를 눌렀다면 취소
    List<String> newDownvotes = List.from(downvotes);
    if (downvotes.contains(userId)) {
      newDownvotes.remove(userId);
    }

    // 좋아요 추가 및 시간 연장 (30분)
    final newUpvotes = List<String>.from(upvotes)..add(userId);
    final newDuration = Duration(minutes: duration.inMinutes + 30);

    return copyWith(
      upvotes: newUpvotes,
      downvotes: newDownvotes,
      duration: newDuration,
    );
  }

  // 싫어요 추가 (시간 단축)
  Pulse addDownvote(String userId) {
    if (downvotes.contains(userId)) return this;

    // 이미 좋아요를 눌렀다면 취소
    List<String> newUpvotes = List.from(upvotes);
    if (upvotes.contains(userId)) {
      newUpvotes.remove(userId);
    }

    // 싫어요 추가 및 시간 축소 (30분, 최소 1시간 보장)
    final newDownvotes = List<String>.from(downvotes)..add(userId);
    final newDurationMinutes = Math.max(60, duration.inMinutes - 30); // 최소 1시간
    final newDuration = Duration(minutes: newDurationMinutes);

    return copyWith(
      upvotes: newUpvotes,
      downvotes: newDownvotes,
      duration: newDuration,
    );
  }

  // 수정된 펄스를 생성하는 메서드
  Pulse copyWith({
    String? id,
    String? author,
    String? title,
    String? content,
    String? imageUrl,
    List<String>? tags,
    List<String>? upvotes,
    List<String>? downvotes,
    DateTime? createdAt,
    Duration? duration,
  }) {
    return Pulse(
      id: id ?? this.id,
      author: author ?? this.author,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
    );
  }

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'content': content,
      'imageUrl': imageUrl,
      'tags': tags,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'createdAt': createdAt.toIso8601String(),
      'duration': duration.inSeconds,
    };
  }

  // JSON에서 객체 생성
  factory Pulse.fromJson(Map<String, dynamic> json) {
    // ID 필드 확인
    final id = json['id'] as String? ?? '';

    // 시간 필드 처리
    DateTime createdAt;
    final createdAtValue = json['createdAt'];

    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      createdAt = DateTime.parse(createdAtValue);
    } else {
      createdAt = DateTime.now(); // 기본값
    }

    // 지속 시간 필드 처리
    Duration duration;
    final durationValue = json['duration'];

    if (durationValue is int) {
      duration = Duration(seconds: durationValue);
    } else if (durationValue is String) {
      // 문자열로 저장된 경우 (초 단위)
      duration = Duration(
        seconds: int.tryParse(durationValue) ?? 86400,
      ); // 기본 24시간
    } else {
      duration = const Duration(hours: 24); // 기본값
    }

    // 배열 필드 안전하게 처리
    List<String> tags = [];
    if (json['tags'] != null) {
      if (json['tags'] is List) {
        tags = List<String>.from(
          (json['tags'] as List).map((item) => item.toString()),
        );
      }
    }

    List<String> upvotes = [];
    if (json['upvotes'] != null) {
      if (json['upvotes'] is List) {
        upvotes = List<String>.from(
          (json['upvotes'] as List).map((item) => item.toString()),
        );
      }
    }

    List<String> downvotes = [];
    if (json['downvotes'] != null) {
      if (json['downvotes'] is List) {
        downvotes = List<String>.from(
          (json['downvotes'] as List).map((item) => item.toString()),
        );
      }
    }

    return Pulse(
      id: id,
      author: json['author'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      tags: tags,
      upvotes: upvotes,
      downvotes: downvotes,
      createdAt: createdAt,
      duration: duration,
    );
  }
}
