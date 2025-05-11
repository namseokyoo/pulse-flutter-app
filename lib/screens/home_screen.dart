import 'package:flutter/material.dart';
import '../models/pulse.dart';
import '../services/pulse_service.dart';
import '../widgets/pulse_card.dart';

enum SortOption { latest, remainingAsc, remainingDesc }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PulseService _pulseService = PulseService();
  List<Pulse> _pulses = [];
  SortOption _sortOption = SortOption.latest;

  @override
  void initState() {
    super.initState();
    _loadPulses();
  }

  void _loadPulses() {
    setState(() {
      _pulses = _pulseService.getAllPulses();
      _sortPulses();
    });
  }

  void _sortPulses() {
    setState(() {
      switch (_sortOption) {
        case SortOption.latest:
          // 작성일 기준 정렬 (최신순)
          _pulses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case SortOption.remainingAsc:
          // 남은 시간 기준 정렬 (적은 순 - 오름차순)
          _pulses.sort((a, b) {
            final aDuration = a.createdAt
                .add(a.duration)
                .difference(DateTime.now());
            final bDuration = b.createdAt
                .add(b.duration)
                .difference(DateTime.now());
            return aDuration.compareTo(bDuration);
          });
          break;
        case SortOption.remainingDesc:
          // 남은 시간 기준 정렬 (많은 순 - 내림차순)
          _pulses.sort((a, b) {
            final aDuration = a.createdAt
                .add(a.duration)
                .difference(DateTime.now());
            final bDuration = b.createdAt
                .add(b.duration)
                .difference(DateTime.now());
            return bDuration.compareTo(aDuration);
          });
          break;
      }
    });
  }

  // 정렬 옵션 변경 처리
  void _handleSortOptionChange(SortOption option) {
    setState(() {
      // 남은시간순 옵션이 현재 선택된 상태에서 다시 선택된 경우
      if ((option == SortOption.remainingAsc ||
              option == SortOption.remainingDesc) &&
          (_sortOption == SortOption.remainingAsc ||
              _sortOption == SortOption.remainingDesc)) {
        // 오름차순/내림차순 토글
        _sortOption =
            _sortOption == SortOption.remainingAsc
                ? SortOption.remainingDesc
                : SortOption.remainingAsc;
      } else {
        // 다른 옵션으로 변경
        _sortOption = option;
      }
      _sortPulses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 정렬 옵션 버튼
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 최신순 버튼
              ElevatedButton(
                onPressed: () {
                  _handleSortOptionChange(SortOption.latest);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _sortOption == SortOption.latest
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceVariant,
                  foregroundColor:
                      _sortOption == SortOption.latest
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  minimumSize: const Size(80, 36),
                ),
                child: const Text('최신순', style: TextStyle(fontSize: 12)),
              ),

              const SizedBox(width: 12),

              // 남은시간순 버튼
              ElevatedButton(
                onPressed: () {
                  // 첫 선택시 오름차순, 이미 선택된 경우 토글
                  if (_sortOption == SortOption.remainingAsc) {
                    _handleSortOptionChange(SortOption.remainingDesc);
                  } else if (_sortOption == SortOption.remainingDesc) {
                    _handleSortOptionChange(SortOption.remainingAsc);
                  } else {
                    _handleSortOptionChange(SortOption.remainingAsc);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      (_sortOption == SortOption.remainingAsc ||
                              _sortOption == SortOption.remainingDesc)
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceVariant,
                  foregroundColor:
                      (_sortOption == SortOption.remainingAsc ||
                              _sortOption == SortOption.remainingDesc)
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  minimumSize: const Size(120, 36),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('남은시간순', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Icon(
                      _sortOption == SortOption.remainingDesc
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      size: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 게시글 목록
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _loadPulses();
            },
            child:
                _pulses.isEmpty
                    ? const Center(child: Text('표시할 펄스가 없습니다'))
                    : ListView.builder(
                      itemCount: _pulses.length,
                      itemBuilder: (context, index) {
                        final pulse = _pulses[index];
                        return PulseCard(pulse: pulse, onRefresh: _loadPulses);
                      },
                    ),
          ),
        ),
      ],
    );
  }
}
