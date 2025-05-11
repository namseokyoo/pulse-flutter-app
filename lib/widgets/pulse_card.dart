import 'package:flutter/material.dart';
import '../models/pulse.dart';
import '../routes.dart';

class PulseCard extends StatelessWidget {
  final Pulse pulse;
  final VoidCallback? onRefresh;

  const PulseCard({super.key, required this.pulse, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Routes.navigateTo(
            Routes.pulseDetail,
            arguments: {'pulseId': pulse.id},
          ).then((_) {
            // 디테일 화면에서 돌아왔을 때 목록 새로고침
            if (onRefresh != null) {
              onRefresh!();
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목 행
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목 및 태그
                    Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pulse.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (pulse.tags.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Wrap(
                                spacing: 4,
                                children:
                                    pulse.tags.map((tag) {
                                      return Text(
                                        '#$tag',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue.shade700,
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // 남은 시간
                    Expanded(
                      flex: 3,
                      child: Text(
                        pulse.remainingTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 하단 정보 행 (작성자, 투표 수)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 작성자
                    Text(
                      '작성자: ${pulse.author}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    // 투표 수
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/icons/like.png',
                          width: 16,
                          height: 16,
                          filterQuality: FilterQuality.high,
                          color: Colors.blue.shade300,
                          isAntiAlias: true,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${pulse.upvoteCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Image.asset(
                          'assets/icons/dislike.png',
                          width: 16,
                          height: 16,
                          filterQuality: FilterQuality.high,
                          color: Colors.red.shade300,
                          isAntiAlias: true,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${pulse.downvoteCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
