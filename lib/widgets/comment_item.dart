import 'package:flutter/material.dart';
import '../models/comment.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;
  final List<Comment> replies;
  final Function(String, String) onReply;
  final Function(String) onLike;

  const CommentItem({
    super.key,
    required this.comment,
    required this.replies,
    required this.onReply,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 메인 댓글
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 작성자 정보
              Row(
                children: [
                  Text(
                    comment.author,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(comment.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),

              // 댓글 내용
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(comment.content),
              ),

              // 액션 버튼 (좋아요, 답글)
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => onLike(comment.id),
                    icon: const Icon(Icons.favorite_border, size: 16),
                    label: Text('${comment.likeCount}'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onReply(comment.id, comment.author),
                    child: const Text('답글달기'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 대댓글 목록
        if (replies.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 16, bottom: 16),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(width: 1, color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              children:
                  replies
                      .map(
                        (reply) => Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 0, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 작성자 정보
                              Row(
                                children: [
                                  Text(
                                    reply.author,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDate(reply.createdAt),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),

                              // 댓글 내용
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text(reply.content),
                              ),

                              // 액션 버튼 (좋아요만)
                              TextButton.icon(
                                onPressed: () => onLike(reply.id),
                                icon: const Icon(
                                  Icons.favorite_border,
                                  size: 14,
                                ),
                                label: Text('${reply.likeCount}'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 0,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),

        const Divider(),
      ],
    );
  }

  // 날짜 포맷 헬퍼 메서드
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
