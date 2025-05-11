import 'package:flutter/material.dart';
import '../models/pulse.dart';
import '../models/comment.dart';
import '../services/pulse_service.dart';
import '../widgets/comment_item.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class PulseDetailScreen extends StatefulWidget {
  final String pulseId;

  const PulseDetailScreen({super.key, required this.pulseId});

  @override
  State<PulseDetailScreen> createState() => _PulseDetailScreenState();
}

class _PulseDetailScreenState extends State<PulseDetailScreen> {
  final PulseService _pulseService = PulseService();
  Pulse? _pulse;
  List<Comment> _comments = [];
  bool _isLoading = true;

  // 댓글 입력
  final TextEditingController _commentController = TextEditingController();
  String? _replyToCommentId;
  String? _replyToAuthor;

  @override
  void initState() {
    super.initState();
    _loadPulseData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadPulseData() {
    setState(() {
      _isLoading = true;
    });

    // 펄스 데이터 로드
    final pulse = _pulseService.getPulseById(widget.pulseId);
    if (pulse == null) {
      // 데이터가 없는 경우 처리
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // 댓글 데이터 로드
    final comments = _pulseService.getCommentsForPulse(widget.pulseId);

    setState(() {
      _pulse = pulse;
      _comments = comments;
      _isLoading = false;
    });
  }

  // 좋아요 버튼 클릭 처리
  void _handleUpvote() {
    final authService = AuthService();

    // 로그인 확인
    if (!authService.isLoggedIn) {
      _showLoginRequiredDialog('좋아요');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 펄스 좋아요 처리
    final updatedPulse = _pulseService.upvotePulse(_pulse!.id);
    setState(() {
      _pulse = updatedPulse;
      _isLoading = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('좋아요! 펄스 시간이 30분 연장되었습니다.')));
  }

  // 싫어요 버튼 클릭 처리
  void _handleDownvote() {
    final authService = AuthService();

    // 로그인 확인
    if (!authService.isLoggedIn) {
      _showLoginRequiredDialog('싫어요');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 펄스 싫어요 처리
    final updatedPulse = _pulseService.downvotePulse(_pulse!.id);
    setState(() {
      _pulse = updatedPulse;
      _isLoading = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('싫어요! 펄스 시간이 30분 단축되었습니다.')));
  }

  // 댓글 추가 처리
  void _handleAddComment() {
    final authService = AuthService();

    // 로그인 확인
    if (!authService.isLoggedIn) {
      _showLoginRequiredDialog('댓글 작성');
      return;
    }

    // 댓글 내용이 비어있는지 확인
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('댓글 내용을 입력해주세요')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 댓글 추가
    Comment newComment = _pulseService.addComment(
      pulseId: _pulse!.id,
      parentId: _replyToCommentId,
      content: content,
    );

    // UI 업데이트 및 입력 필드 초기화
    setState(() {
      _comments.add(newComment);
      _commentController.clear();
      _replyToCommentId = null;
      _replyToAuthor = null;
      _isLoading = false;
    });
  }

  // 대댓글 모드 설정
  void _setReplyMode(String commentId, String author) {
    setState(() {
      _replyToCommentId = commentId;
      _replyToAuthor = author;
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  // 대댓글 모드 취소
  void _cancelReplyMode() {
    setState(() {
      _replyToCommentId = null;
      _replyToAuthor = null;
    });
  }

  // 댓글 좋아요 처리
  void _handleLikeComment(String commentId) {
    final updatedComment = _pulseService.likeComment(commentId);
    if (updatedComment != null) {
      setState(() {
        final index = _comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          _comments[index] = updatedComment;
        }
      });
    }
  }

  // 로그인 필요 다이얼로그 표시
  void _showLoginRequiredDialog(String action) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('로그인 필요'),
            content: Text('$action 기능을 사용하려면 로그인이 필요합니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      )
                      .then((_) {
                        // 로그인 후 돌아오면 펄스 정보 새로고침
                        _loadPulseData();
                      });
                },
                child: const Text('로그인하기'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('로딩 중...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_pulse == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('게시글 없음')),
        body: const Center(child: Text('게시글을 찾을 수 없습니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_pulse!.title, style: const TextStyle(fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPulseData,
          ),
        ],
      ),
      body: Column(
        children: [
          // 게시글 내용
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 게시글 헤더 (작성자, 날짜 등)
                  Container(
                    color: Colors.grey.shade50,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _pulse!.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '작성자: ${_pulse!.author}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '남은 시간: ${_pulse!.remainingTime}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        if (_pulse!.tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children:
                                _pulse!.tags.map((tag) {
                                  return Chip(
                                    label: Text('#$tag'),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    labelStyle: const TextStyle(fontSize: 12),
                                    padding: EdgeInsets.zero,
                                  );
                                }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 게시글 본문
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_pulse!.content),
                        if (_pulse!.imageUrl != null) ...[
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _pulse!.imageUrl!,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(
                                  height: 100,
                                  child: Center(child: Icon(Icons.error)),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 투표 버튼 (좋아요/싫어요)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '투표: ${_pulse!.upvoteCount} 좋아요, ${_pulse!.downvoteCount} 싫어요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Row(
                          children: [
                            // 좋아요 버튼
                            ElevatedButton.icon(
                              onPressed: _handleUpvote,
                              icon: Image.asset(
                                'assets/icons/like.png',
                                width: 22,
                                height: 22,
                                filterQuality: FilterQuality.high,
                                isAntiAlias: true,
                              ),
                              label: const Text('좋아요'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade100,
                                foregroundColor: Colors.blue.shade800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 싫어요 버튼
                            ElevatedButton.icon(
                              onPressed: _handleDownvote,
                              icon: Image.asset(
                                'assets/icons/dislike.png',
                                width: 22,
                                height: 22,
                                filterQuality: FilterQuality.high,
                                isAntiAlias: true,
                              ),
                              label: const Text('싫어요'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade100,
                                foregroundColor: Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(thickness: 1),

                  // 댓글 섹션
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '댓글 ${_comments.length}개',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            // 부모 댓글만 표시
                            if (comment.parentId == null) {
                              return CommentItem(
                                comment: comment,
                                replies:
                                    _comments
                                        .where((c) => c.parentId == comment.id)
                                        .toList(),
                                onReply: _setReplyMode,
                                onLike: _handleLikeComment,
                              );
                            } else {
                              // 대댓글은 부모 댓글과 함께 표시
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 대댓글 모드 표시
          if (_replyToAuthor != null)
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '@$_replyToAuthor에게 답글 작성 중',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: _cancelReplyMode,
                  ),
                ],
              ),
            ),

          // 댓글 입력
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  offset: const Offset(0, -1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText:
                          _replyToAuthor != null
                              ? '답글을 입력하세요...'
                              : '댓글을 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _handleAddComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
