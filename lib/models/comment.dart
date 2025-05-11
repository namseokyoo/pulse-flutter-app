import 'package:uuid/uuid.dart';

class Comment {
  final String id;
  final String pulseId; // 연결된 펄스 ID
  final String? parentId; // 부모 댓글 ID (대댓글인 경우)
  final String author;
  final String content;
  final DateTime createdAt;
  final List<String> likes; // 좋아요 누른 사용자 ID 목록

  Comment({
    required this.id,
    required this.pulseId,
    this.parentId,
    required this.author,
    required this.content,
    required this.createdAt,
    this.likes = const [],
  });

  // 좋아요 수 계산
  int get likeCount => likes.length;

  // 대댓글인지 확인
  bool get isReply => parentId != null;

  // 댓글 생성 팩토리 메서드
  factory Comment.create({
    required String pulseId,
    String? parentId,
    required String author,
    required String content,
  }) {
    return Comment(
      id: const Uuid().v4(),
      pulseId: pulseId,
      parentId: parentId,
      author: author,
      content: content,
      createdAt: DateTime.now(),
    );
  }

  // 새 좋아요 추가
  Comment addLike(String userId) {
    if (likes.contains(userId)) return this;

    final newLikes = List<String>.from(likes)..add(userId);
    return copyWith(likes: newLikes);
  }

  // 좋아요 취소
  Comment removeLike(String userId) {
    if (!likes.contains(userId)) return this;

    final newLikes = List<String>.from(likes)..remove(userId);
    return copyWith(likes: newLikes);
  }

  // 복사본 생성
  Comment copyWith({
    String? id,
    String? pulseId,
    String? parentId,
    String? author,
    String? content,
    DateTime? createdAt,
    List<String>? likes,
  }) {
    return Comment(
      id: id ?? this.id,
      pulseId: pulseId ?? this.pulseId,
      parentId: parentId ?? this.parentId,
      author: author ?? this.author,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
    );
  }

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pulseId': pulseId,
      'parentId': parentId,
      'author': author,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
    };
  }

  // JSON에서 객체 생성
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      pulseId: json['pulseId'],
      parentId: json['parentId'],
      author: json['author'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      likes: List<String>.from(json['likes'] ?? []),
    );
  }
}
