import 'dart:math' as Math;

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

  // JSON 변환을 위한 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'tags': tags,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'createdAt': createdAt.toIso8601String(),
      'duration': duration.inSeconds,
    };
  }

  // JSON에서 객체 생성을 위한 팩토리 메서드
  factory Pulse.fromJson(Map<String, dynamic> json) {
    return Pulse(
      id: json['id'],
      author: json['author'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags'] ?? []),
      upvotes: List<String>.from(json['upvotes'] ?? []),
      downvotes: List<String>.from(json['downvotes'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      duration: Duration(seconds: json['duration']),
    );
  }
}
