import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/pulse.dart';
import '../models/comment.dart';
import 'auth_service.dart';

class PulseService {
  // 싱글턴 패턴 구현
  static final PulseService _instance = PulseService._internal();
  factory PulseService() => _instance;
  PulseService._internal();

  // Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final _uuid = const Uuid();

  // 현재 사용자 ID
  String get currentUserId {
    final user = _authService.currentUser;
    return user?.id ?? 'anonymous-${DateTime.now().millisecondsSinceEpoch}';
  }

  // 펄스 컬렉션 참조
  CollectionReference get _pulsesCollection => _firestore.collection('pulses');

  // 댓글 컬렉션 참조
  CollectionReference get _commentsCollection =>
      _firestore.collection('comments');

  // 모든 펄스 가져오기
  Future<List<Pulse>> getAllPulses() async {
    try {
      if (kDebugMode) {
        print('Firestore에서 펄스 데이터 로드 시작');
      }

      // 만료되지 않은 펄스만 가져오기
      final now = DateTime.now();
      final QuerySnapshot snapshot = await _pulsesCollection.get();

      if (kDebugMode) {
        print('Firestore 쿼리 성공: ${snapshot.docs.length}개의 문서 가져옴');
      }

      List<Pulse> pulses = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // 문서 ID를 펄스 ID로 사용
        data['id'] = doc.id;

        // Firestore에서 데이터를 가져와 Pulse 객체로 변환
        try {
          final pulse = Pulse.fromJson(data);

          // 만료된 펄스는 제외
          final expiresAt = pulse.createdAt.add(pulse.duration);
          if (expiresAt.isAfter(now)) {
            pulses.add(pulse);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Pulse 변환 중 오류 (ID: ${doc.id}): $e');
          }
        }
      }

      // 생성일시 기준 내림차순 정렬 (최신순)
      pulses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (kDebugMode) {
        print('펄스 데이터 로드 완료: ${pulses.length}개의 유효한 펄스');
      }

      return pulses;
    } catch (e) {
      if (kDebugMode) {
        print('펄스 목록 로드 중 오류: $e');
        print('오류 세부 정보: ${e.toString()}');
      }
      return [];
    }
  }

  // 새 펄스 생성
  Future<Pulse?> createPulse({
    required String title,
    required String content,
    required String author,
    String? imageUrl,
    List<String>? tags,
    Duration duration = const Duration(hours: 24),
  }) async {
    try {
      final now = DateTime.now();

      // Firestore에 저장할 데이터
      final pulseData = {
        'title': title,
        'author': author,
        'content': content,
        'imageUrl': imageUrl,
        'tags': tags ?? [],
        'upvotes': [],
        'downvotes': [],
        'createdAt': now.toIso8601String(),
        'duration': duration.inSeconds,
      };

      // Firestore에 저장
      final docRef = await _pulsesCollection.add(pulseData);

      // 생성된 Pulse 객체 반환
      return Pulse(
        id: docRef.id,
        title: title,
        author: author,
        content: content,
        imageUrl: imageUrl,
        tags: tags ?? [],
        upvotes: [],
        downvotes: [],
        createdAt: now,
        duration: duration,
      );
    } catch (e) {
      if (kDebugMode) {
        print('펄스 생성 중 오류: $e');
      }
      return null;
    }
  }

  // 펄스 상세 정보 가져오기
  Future<Pulse?> getPulseById(String id) async {
    try {
      final docSnap = await _pulsesCollection.doc(id).get();
      if (!docSnap.exists) {
        return null;
      }

      final data = docSnap.data() as Map<String, dynamic>;
      // 문서 ID를 펄스 ID로 사용
      data['id'] = docSnap.id;

      return Pulse.fromJson(data);
    } catch (e) {
      if (kDebugMode) {
        print('펄스 상세 정보 로드 중 오류: $e');
      }
      return null;
    }
  }

  // 펄스에 좋아요 추가 (시간 연장)
  Future<Pulse?> upvotePulse(String id) async {
    try {
      // 트랜잭션 사용하여 동시성 이슈 방지
      return await _firestore.runTransaction<Pulse?>((transaction) async {
        final docRef = _pulsesCollection.doc(id);
        final docSnap = await transaction.get(docRef);

        if (!docSnap.exists) {
          return null;
        }

        final data = docSnap.data() as Map<String, dynamic>;
        data['id'] = docSnap.id;

        final pulse = Pulse.fromJson(data);
        final updatedPulse = pulse.addUpvote(currentUserId);

        // Firestore에 업데이트할 데이터
        final updateData = {
          'upvotes': updatedPulse.upvotes,
          'duration': updatedPulse.duration.inSeconds,
        };

        // 이미 싫어요를 눌렀었다면 제거
        if (pulse.downvotes.contains(currentUserId)) {
          final downvotes = List<String>.from(pulse.downvotes);
          downvotes.remove(currentUserId);
          updateData['downvotes'] = downvotes;
        }

        transaction.update(docRef, updateData);
        return updatedPulse;
      });
    } catch (e) {
      if (kDebugMode) {
        print('펄스 좋아요 중 오류: $e');
      }
      return null;
    }
  }

  // 펄스에 싫어요 추가 (시간 축소)
  Future<Pulse?> downvotePulse(String id) async {
    try {
      // 트랜잭션 사용하여 동시성 이슈 방지
      return await _firestore.runTransaction<Pulse?>((transaction) async {
        final docRef = _pulsesCollection.doc(id);
        final docSnap = await transaction.get(docRef);

        if (!docSnap.exists) {
          return null;
        }

        final data = docSnap.data() as Map<String, dynamic>;
        data['id'] = docSnap.id;

        final pulse = Pulse.fromJson(data);
        final updatedPulse = pulse.addDownvote(currentUserId);

        // Firestore에 업데이트할 데이터
        final updateData = {
          'downvotes': updatedPulse.downvotes,
          'duration': updatedPulse.duration.inSeconds,
        };

        // 이미 좋아요를 눌렀었다면 제거
        if (pulse.upvotes.contains(currentUserId)) {
          final upvotes = List<String>.from(pulse.upvotes);
          upvotes.remove(currentUserId);
          updateData['upvotes'] = upvotes;
        }

        transaction.update(docRef, updateData);
        return updatedPulse;
      });
    } catch (e) {
      if (kDebugMode) {
        print('펄스 싫어요 중 오류: $e');
      }
      return null;
    }
  }

  // 펄스의 모든 댓글 가져오기
  Future<List<Comment>> getCommentsForPulse(String pulseId) async {
    try {
      final QuerySnapshot snapshot =
          await _commentsCollection.where('pulseId', isEqualTo: pulseId).get();

      List<Comment> comments = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // 문서 ID를 댓글 ID로 사용
        data['id'] = doc.id;

        try {
          final comment = Comment.fromJson(data);
          comments.add(comment);
        } catch (e) {
          if (kDebugMode) {
            print('댓글 변환 중 오류: $e');
          }
        }
      }

      // 생성일시 기준 오름차순 정렬 (오래된순)
      comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return comments;
    } catch (e) {
      if (kDebugMode) {
        print('댓글 목록 로드 중 오류: $e');
      }
      return [];
    }
  }

  // 새 댓글 작성
  Future<Comment?> addComment({
    required String pulseId,
    String? parentId,
    required String content,
  }) async {
    try {
      final now = DateTime.now();
      final user = _authService.currentUser;
      final author = user?.username ?? 'Anonymous';

      // Firestore에 저장할 데이터
      final commentData = {
        'pulseId': pulseId,
        'parentId': parentId,
        'author': author,
        'content': content,
        'createdAt': now.toIso8601String(),
        'likes': [],
      };

      // Firestore에 저장
      final docRef = await _commentsCollection.add(commentData);

      // 생성된 Comment 객체 반환
      return Comment(
        id: docRef.id,
        pulseId: pulseId,
        parentId: parentId,
        author: author,
        content: content,
        createdAt: now,
        likes: [],
      );
    } catch (e) {
      if (kDebugMode) {
        print('댓글 생성 중 오류: $e');
      }
      return null;
    }
  }

  // 댓글에 좋아요 추가
  Future<Comment?> likeComment(String commentId) async {
    try {
      // 트랜잭션 사용하여 동시성 이슈 방지
      return await _firestore.runTransaction<Comment?>((transaction) async {
        final docRef = _commentsCollection.doc(commentId);
        final docSnap = await transaction.get(docRef);

        if (!docSnap.exists) {
          return null;
        }

        final data = docSnap.data() as Map<String, dynamic>;
        data['id'] = docSnap.id;

        final comment = Comment.fromJson(data);
        final updatedComment = comment.addLike(currentUserId);

        // Firestore에 업데이트
        transaction.update(docRef, {'likes': updatedComment.likes});

        return updatedComment;
      });
    } catch (e) {
      if (kDebugMode) {
        print('댓글 좋아요 중 오류: $e');
      }
      return null;
    }
  }

  // 댓글 삭제
  Future<bool> deleteComment(String commentId) async {
    try {
      // 먼저 대댓글들 찾기
      final QuerySnapshot repliesSnapshot =
          await _commentsCollection
              .where('parentId', isEqualTo: commentId)
              .get();

      // 트랜잭션으로 댓글과 대댓글 모두 삭제
      await _firestore.runTransaction((transaction) async {
        // 대댓글 삭제
        for (var doc in repliesSnapshot.docs) {
          transaction.delete(doc.reference);
        }

        // 댓글 자체 삭제
        transaction.delete(_commentsCollection.doc(commentId));
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('댓글 삭제 중 오류: $e');
      }
      return false;
    }
  }

  // 펄스 삭제 (댓글도 함께 삭제)
  Future<bool> deletePulse(String id) async {
    try {
      // 먼저 관련 댓글들 찾기
      final QuerySnapshot commentsSnapshot =
          await _commentsCollection.where('pulseId', isEqualTo: id).get();

      // 트랜잭션으로 펄스와 모든 관련 댓글 삭제
      await _firestore.runTransaction((transaction) async {
        // 관련 댓글 모두 삭제
        for (var doc in commentsSnapshot.docs) {
          transaction.delete(doc.reference);
        }

        // 펄스 자체 삭제
        transaction.delete(_pulsesCollection.doc(id));
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('펄스 삭제 중 오류: $e');
      }
      return false;
    }
  }

  // 태그로 펄스 검색
  Future<List<Pulse>> searchPulsesByTag(String tag) async {
    try {
      final now = DateTime.now();
      final QuerySnapshot snapshot =
          await _pulsesCollection.where('tags', arrayContains: tag).get();

      List<Pulse> pulses = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        try {
          final pulse = Pulse.fromJson(data);

          // 만료된 펄스는 제외
          final expiresAt = pulse.createdAt.add(pulse.duration);
          if (expiresAt.isAfter(now)) {
            pulses.add(pulse);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Pulse 변환 중 오류: $e');
          }
        }
      }

      // 생성일시 기준 내림차순 정렬 (최신순)
      pulses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return pulses;
    } catch (e) {
      if (kDebugMode) {
        print('태그 검색 중 오류: $e');
      }
      return [];
    }
  }

  // Firestore에 초기 데이터 설정 (테스트/개발용)
  Future<void> setupInitialData() async {
    try {
      // 컬렉션이 비어있는지 확인
      final pulsesSnapshot = await _pulsesCollection.limit(1).get();

      if (pulsesSnapshot.docs.isEmpty) {
        if (kDebugMode) {
          print('Firestore에 초기 데이터 설정 중...');
        }

        final now = DateTime.now();

        // 샘플 펄스 생성
        final pulse1 = await createPulse(
          title: '펄스 테스트 게시글입니다',
          author: '익명1',
          content: '이 펄스는 테스트입니다. 게시판 스타일로 표시됩니다.',
          tags: ['테스트', '공지'],
        );

        final pulse2 = await createPulse(
          title: 'Flutter 개발 후기',
          author: '익명2',
          content: 'Flutter 너무 재밌다! 다양한 UI 컴포넌트를 쉽게 사용할 수 있어서 개발이 빠르게 진행됩니다.',
          tags: ['Flutter', '개발'],
        );

        final pulse3 = await createPulse(
          title: '펄스 앱 소개',
          author: '익명3',
          content: '이 앱은 펄스 기반입니다. 24시간 동안만 게시물이 유지되는 특별한 게시판 앱입니다.',
          imageUrl: 'https://picsum.photos/200',
          tags: ['앱', '펄스'],
        );

        // 첫 번째 펄스에 댓글 추가
        if (pulse1 != null) {
          final comment1 = await addComment(
            pulseId: pulse1.id,
            content: '정말 유용한 정보네요!',
          );

          await addComment(pulseId: pulse1.id, content: '응원합니다~');

          // 대댓글 추가
          if (comment1 != null) {
            await addComment(
              pulseId: pulse1.id,
              parentId: comment1.id,
              content: '저도 동의합니다!',
            );
          }
        }

        // 두 번째 펄스에 댓글 추가
        if (pulse2 != null) {
          await addComment(
            pulseId: pulse2.id,
            content: 'Flutter로 개발 시작했는데 정말 좋네요',
          );
        }

        if (kDebugMode) {
          print('초기 데이터 설정 완료!');
        }
      } else {
        if (kDebugMode) {
          print('Firestore에 이미 데이터가 있습니다. 초기 데이터를 설정하지 않습니다.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('초기 데이터 설정 중 오류: $e');
      }
    }
  }
}
