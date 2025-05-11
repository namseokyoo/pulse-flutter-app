import 'package:uuid/uuid.dart';
import '../models/pulse.dart';
import '../models/comment.dart';

class PulseService {
  // 싱글턴 패턴 구현
  static final PulseService _instance = PulseService._internal();
  factory PulseService() => _instance;
  PulseService._internal();

  final List<Pulse> _pulses = [];
  final List<Comment> _comments = []; // 댓글 저장소
  final _uuid = const Uuid();

  // 현재 사용자 ID (실제로는 인증 시스템에서 가져와야 함)
  String get currentUserId => 'user-${DateTime.now().millisecondsSinceEpoch}';

  // 모든 펄스 가져오기
  List<Pulse> getAllPulses() {
    // 만료된 펄스는 제외
    final now = DateTime.now();
    return _pulses.where((pulse) {
      final expiresAt = pulse.createdAt.add(pulse.duration);
      return expiresAt.isAfter(now);
    }).toList();
  }

  // 새 펄스 생성
  Pulse createPulse({
    required String title,
    required String content,
    required String author,
    String? imageUrl,
    List<String>? tags,
    Duration duration = const Duration(hours: 24),
  }) {
    final pulse = Pulse(
      id: _uuid.v4(),
      title: title,
      author: author,
      content: content,
      imageUrl: imageUrl,
      tags: tags ?? [],
      createdAt: DateTime.now(),
      duration: duration,
    );

    _pulses.add(pulse);
    return pulse;
  }

  // 펄스 상세 정보 가져오기
  Pulse? getPulseById(String id) {
    final index = _pulses.indexWhere((pulse) => pulse.id == id);
    if (index == -1) {
      return null;
    }
    return _pulses[index];
  }

  // 펄스에 좋아요 추가 (시간 연장)
  Pulse? upvotePulse(String id) {
    final index = _pulses.indexWhere((pulse) => pulse.id == id);
    if (index == -1) {
      return null;
    }

    final pulse = _pulses[index];
    final updatedPulse = pulse.addUpvote(currentUserId);
    _pulses[index] = updatedPulse;
    return updatedPulse;
  }

  // 펄스에 싫어요 추가 (시간 축소)
  Pulse? downvotePulse(String id) {
    final index = _pulses.indexWhere((pulse) => pulse.id == id);
    if (index == -1) {
      return null;
    }

    final pulse = _pulses[index];
    final updatedPulse = pulse.addDownvote(currentUserId);
    _pulses[index] = updatedPulse;
    return updatedPulse;
  }

  // 펄스의 모든 댓글 가져오기
  List<Comment> getCommentsForPulse(String pulseId) {
    return _comments.where((comment) => comment.pulseId == pulseId).toList();
  }

  // 댓글의 대댓글 가져오기
  List<Comment> getRepliesForComment(String commentId) {
    return _comments.where((comment) => comment.parentId == commentId).toList();
  }

  // 새 댓글 작성
  Comment addComment({
    required String pulseId,
    String? parentId,
    required String content,
  }) {
    final comment = Comment.create(
      pulseId: pulseId,
      parentId: parentId,
      author: 'Anonymous', // 실제 구현에서는 현재 사용자 이름으로 변경
      content: content,
    );

    _comments.add(comment);
    return comment;
  }

  // 댓글에 좋아요 추가
  Comment? likeComment(String commentId) {
    final index = _comments.indexWhere((comment) => comment.id == commentId);
    if (index == -1) {
      return null;
    }

    final comment = _comments[index];
    final updatedComment = comment.addLike(currentUserId);
    _comments[index] = updatedComment;
    return updatedComment;
  }

  // 댓글 삭제
  bool deleteComment(String commentId) {
    final index = _comments.indexWhere((comment) => comment.id == commentId);
    if (index == -1) {
      return false;
    }

    // 먼저 이 댓글의 모든 대댓글 삭제
    _comments.removeWhere((comment) => comment.parentId == commentId);

    // 댓글 자체 삭제
    _comments.removeAt(index);
    return true;
  }

  // 펄스 삭제 (댓글도 함께 삭제)
  void deletePulse(String id) {
    _pulses.removeWhere((pulse) => pulse.id == id);
    // 해당 펄스의 모든 댓글도 삭제
    _comments.removeWhere((comment) => comment.pulseId == id);
  }

  // 태그로 펄스 검색
  List<Pulse> searchPulsesByTag(String tag) {
    final now = DateTime.now();
    return _pulses.where((pulse) {
      final expiresAt = pulse.createdAt.add(pulse.duration);
      return expiresAt.isAfter(now) && pulse.tags.contains(tag);
    }).toList();
  }

  // 샘플 데이터 로드
  void loadMockData() {
    final now = DateTime.now();

    // 샘플 펄스 데이터
    final pulse1 = Pulse(
      id: _uuid.v4(),
      title: '펄스 테스트 게시글입니다',
      author: '익명1',
      content: '이 펄스는 테스트입니다. 게시판 스타일로 표시됩니다.',
      tags: ['테스트', '공지'],
      upvotes: ['user1', 'user2'],
      downvotes: [],
      createdAt: now.subtract(const Duration(hours: 1)),
    );

    final pulse2 = Pulse(
      id: _uuid.v4(),
      title: 'Flutter 개발 후기',
      author: '익명2',
      content: 'Flutter 너무 재밌다! 다양한 UI 컴포넌트를 쉽게 사용할 수 있어서 개발이 빠르게 진행됩니다.',
      tags: ['Flutter', '개발'],
      upvotes: ['user3'],
      downvotes: ['user4'],
      createdAt: now.subtract(const Duration(hours: 11, minutes: 15)),
    );

    final pulse3 = Pulse(
      id: _uuid.v4(),
      title: '펄스 앱 소개',
      author: '익명3',
      content: '이 앱은 펄스 기반입니다. 24시간 동안만 게시물이 유지되는 특별한 게시판 앱입니다.',
      imageUrl: 'https://picsum.photos/200',
      tags: ['앱', '펄스'],
      upvotes: ['user1', 'user5', 'user6'],
      downvotes: ['user2'],
      createdAt: now.subtract(const Duration(hours: 22, minutes: 55)),
    );

    _pulses.addAll([pulse1, pulse2, pulse3]);

    // 샘플 댓글 데이터
    final comment1 = Comment(
      id: _uuid.v4(),
      pulseId: pulse1.id,
      author: '익명4',
      content: '정말 유용한 정보네요!',
      createdAt: now.subtract(const Duration(minutes: 30)),
      likes: ['user2', 'user5'],
    );

    final comment2 = Comment(
      id: _uuid.v4(),
      pulseId: pulse1.id,
      author: '익명5',
      content: '응원합니다~',
      createdAt: now.subtract(const Duration(minutes: 20)),
    );

    final reply1 = Comment(
      id: _uuid.v4(),
      pulseId: pulse1.id,
      parentId: comment1.id,
      author: '익명6',
      content: '저도 동의합니다!',
      createdAt: now.subtract(const Duration(minutes: 15)),
    );

    final comment3 = Comment(
      id: _uuid.v4(),
      pulseId: pulse2.id,
      author: '익명7',
      content: 'Flutter로 개발 시작했는데 정말 좋네요',
      createdAt: now.subtract(const Duration(minutes: 45)),
    );

    _comments.addAll([comment1, comment2, reply1, comment3]);
  }
}
