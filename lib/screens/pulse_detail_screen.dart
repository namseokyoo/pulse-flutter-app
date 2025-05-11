import 'package:flutter/material.dart';
import '../models/pulse.dart';
import '../models/comment.dart';
import '../services/pulse_service.dart';
import '../widgets/comment_item.dart';
import '../services/auth_service.dart';
import '../routes.dart';
import '../main.dart'; // AppColors 사용

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
  bool _isVoting = false;
  bool _isSubmittingComment = false;

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

  // 펄스 데이터 로드
  Future<void> _loadPulseData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 펄스 데이터 로드
      final pulse = await _pulseService.getPulseById(widget.pulseId);
      if (pulse == null) {
        // 데이터가 없는 경우 처리
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // 댓글 데이터 로드
      final comments = await _pulseService.getCommentsForPulse(widget.pulseId);

      if (mounted) {
        setState(() {
          _pulse = pulse;
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('펄스 데이터 로드 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 좋아요 버튼 클릭 처리
  Future<void> _handleUpvote() async {
    final authService = AuthService();
    if (!authService.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    setState(() {
      _isVoting = true;
    });

    try {
      final updatedPulse = await _pulseService.upvotePulse(_pulse!.id);
      if (updatedPulse != null && mounted) {
        setState(() {
          _pulse = updatedPulse;
          _isVoting = false;
        });
      }
    } catch (e) {
      debugPrint('좋아요 오류: $e');
      if (mounted) {
        setState(() {
          _isVoting = false;
        });
      }
    }
  }

  // 싫어요 버튼 클릭 처리
  Future<void> _handleDownvote() async {
    final authService = AuthService();
    if (!authService.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    setState(() {
      _isVoting = true;
    });

    try {
      final updatedPulse = await _pulseService.downvotePulse(_pulse!.id);
      if (updatedPulse != null && mounted) {
        setState(() {
          _pulse = updatedPulse;
          _isVoting = false;
        });
      }
    } catch (e) {
      debugPrint('싫어요 오류: $e');
      if (mounted) {
        setState(() {
          _isVoting = false;
        });
      }
    }
  }

  // 댓글 작성 처리
  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    final authService = AuthService();
    if (!authService.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    setState(() {
      _isSubmittingComment = true;
    });

    try {
      final newComment = await _pulseService.addComment(
        pulseId: widget.pulseId,
        parentId: _replyToCommentId,
        content: _commentController.text.trim(),
      );

      if (newComment != null && mounted) {
        setState(() {
          _comments.add(newComment);
          _commentController.clear();
          _replyToCommentId = null;
          _replyToAuthor = null;
          _isSubmittingComment = false;
        });
      }
    } catch (e) {
      debugPrint('댓글 작성 오류: $e');
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
        });
      }
    }
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
  Future<void> _handleLikeComment(String commentId) async {
    final authService = AuthService();
    if (!authService.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    try {
      final updatedComment = await _pulseService.likeComment(commentId);
      if (updatedComment != null && mounted) {
        setState(() {
          // 기존 댓글 찾아서 업데이트된 댓글로 교체
          final index = _comments.indexWhere((c) => c.id == commentId);
          if (index != -1) {
            _comments[index] = updatedComment;
          }
        });
      }
    } catch (e) {
      debugPrint('댓글 좋아요 처리 오류: $e');
    }
  }

  // 로그인 필요 다이얼로그 표시
  void _showLoginRequiredDialog() {
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
                  Navigator.pop(context);
                  Routes.navigateTo(Routes.login);
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
                    color: AppColors.cardBackground,
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
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '작성자: ${_pulse!.author}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '남은 시간: ${_pulse!.remainingTime}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
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
                                    backgroundColor: AppColors.background,
                                    labelPadding: EdgeInsets.zero,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
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
                        Text(
                          _pulse!.content,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
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
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Row(
                          children: [
                            // 좋아요 버튼
                            ElevatedButton.icon(
                              onPressed: _isVoting ? null : _handleUpvote,
                              icon: const Icon(Icons.favorite, size: 20),
                              label: const Text('좋아요'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.primaryBlue
                                    .withOpacity(0.5),
                                disabledForegroundColor: Colors.white70,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 싫어요 버튼
                            ElevatedButton.icon(
                              onPressed: _isVoting ? null : _handleDownvote,
                              icon: const Icon(Icons.thumb_down, size: 20),
                              label: const Text('싫어요'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentRed,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.accentRed
                                    .withOpacity(0.5),
                                disabledForegroundColor: Colors.white70,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(thickness: 1, color: AppColors.divider),

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
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 댓글 목록 (Expanded 제거하고 직접 높이 설정)
                        _comments.isEmpty
                            ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  '아직 댓글이 없습니다',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                            : ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 500, // 최대 높이 설정
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: _comments.length,
                                itemBuilder: (context, index) {
                                  final comment = _comments[index];
                                  // 대댓글이 아닌 댓글만 표시
                                  if (comment.parentId == null) {
                                    // 이 댓글에 대한 대댓글 찾기
                                    final replies =
                                        _comments
                                            .where(
                                              (c) => c.parentId == comment.id,
                                            )
                                            .toList();
                                    return CommentItem(
                                      comment: comment,
                                      replies: replies,
                                      onReply: () {
                                        _setReplyMode(
                                          comment.id,
                                          comment.author,
                                        );
                                      },
                                      onLike: () {
                                        _handleLikeComment(comment.id);
                                      },
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
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
              padding: const EdgeInsets.all(8),
              color: AppColors.cardBackground,
              child: Row(
                children: [
                  Text(
                    '@$_replyToAuthor에게 답글 작성 중',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: _cancelReplyMode,
                  ),
                ],
              ),
            ),

          // 댓글 입력 필드
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText:
                          _replyToAuthor != null
                              ? '@$_replyToAuthor에게 답글 달기...'
                              : '댓글을 입력하세요...',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      fillColor: AppColors.cardBackground,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                _isSubmittingComment
                    ? const CircularProgressIndicator()
                    : Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryBlue,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _submitComment,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
