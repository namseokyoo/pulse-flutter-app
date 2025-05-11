import 'package:flutter/material.dart';
import '../models/pulse.dart';
import '../services/pulse_service.dart';
import '../widgets/pulse_card.dart';

class LikedPulsesScreen extends StatefulWidget {
  final String userId;

  const LikedPulsesScreen({super.key, required this.userId});

  @override
  State<LikedPulsesScreen> createState() => _LikedPulsesScreenState();
}

class _LikedPulsesScreenState extends State<LikedPulsesScreen>
    with SingleTickerProviderStateMixin {
  final PulseService _pulseService = PulseService();
  List<Pulse> _likedPulses = [];
  List<Pulse> _dislikedPulses = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInteractedPulses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadInteractedPulses() {
    setState(() {
      _isLoading = true;
    });

    // 모든 펄스 가져오기
    final allPulses = _pulseService.getAllPulses();

    // 좋아요한 펄스만 필터링
    final likedPulses =
        allPulses
            .where((pulse) => pulse.upvotes.contains(widget.userId))
            .toList();

    // 싫어요한 펄스만 필터링
    final dislikedPulses =
        allPulses
            .where((pulse) => pulse.downvotes.contains(widget.userId))
            .toList();

    setState(() {
      _likedPulses = likedPulses;
      _dislikedPulses = dislikedPulses;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('좋아요/싫어요한 펄스'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInteractedPulses,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Image.asset(
                'assets/icons/like.png',
                width: 26,
                height: 26,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
              ),
              text: '좋아요 (${_likedPulses.length})',
            ),
            Tab(
              icon: Image.asset(
                'assets/icons/dislike.png',
                width: 26,
                height: 26,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
              ),
              text: '싫어요 (${_dislikedPulses.length})',
            ),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  // 좋아요 탭
                  _likedPulses.isEmpty
                      ? const Center(child: Text('좋아요한 펄스가 없습니다'))
                      : RefreshIndicator(
                        onRefresh: () async {
                          _loadInteractedPulses();
                        },
                        child: ListView.builder(
                          itemCount: _likedPulses.length,
                          itemBuilder: (context, index) {
                            final pulse = _likedPulses[index];
                            return PulseCard(
                              pulse: pulse,
                              onRefresh: _loadInteractedPulses,
                            );
                          },
                        ),
                      ),

                  // 싫어요 탭
                  _dislikedPulses.isEmpty
                      ? const Center(child: Text('싫어요한 펄스가 없습니다'))
                      : RefreshIndicator(
                        onRefresh: () async {
                          _loadInteractedPulses();
                        },
                        child: ListView.builder(
                          itemCount: _dislikedPulses.length,
                          itemBuilder: (context, index) {
                            final pulse = _dislikedPulses[index];
                            return PulseCard(
                              pulse: pulse,
                              onRefresh: _loadInteractedPulses,
                            );
                          },
                        ),
                      ),
                ],
              ),
    );
  }
}
