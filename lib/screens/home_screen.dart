import 'package:flutter/material.dart';
import '../models/pulse.dart';
import '../services/pulse_service.dart';
import '../widgets/pulse_card.dart';

enum SortOption { latest, remainingAsc, remainingDesc }

// HomeScreen 상태에 접근하기 위한 싱글톤 패턴
class HomeScreenState {
  static final HomeScreenState _instance = HomeScreenState._internal();
  factory HomeScreenState() => _instance;
  HomeScreenState._internal();

  _HomeScreenState? currentState;

  void refreshData() {
    currentState?._loadPulses();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final PulseService _pulseService = PulseService();
  List<Pulse> _pulses = [];
  SortOption _sortOption = SortOption.latest;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    HomeScreenState().currentState = this;
    _loadPulses();
  }

  @override
  void dispose() {
    if (HomeScreenState().currentState == this) {
      HomeScreenState().currentState = null;
    }
    super.dispose();
  }

  // 펄스 데이터 로드
  Future<void> _loadPulses() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final pulses = await _pulseService.getAllPulses();
      if (!mounted) return;

      setState(() {
        _pulses = pulses;
        _sortPulses(); // 정렬 적용
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('펄스 로드 오류: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // 펄스 정렬
  void _sortPulses() {
    setState(() {
      switch (_sortOption) {
        case SortOption.latest:
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
    super.build(context);
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
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _pulses.isEmpty
                    ? ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(child: Text('표시할 펄스가 없습니다')),
                        SizedBox(height: 100),
                      ],
                    )
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
