import 'package:flutter/material.dart';
import '../models/pulse.dart';
import '../services/pulse_service.dart';
import '../widgets/pulse_card.dart';

class MyPulsesScreen extends StatefulWidget {
  final String userId;

  const MyPulsesScreen({super.key, required this.userId});

  @override
  State<MyPulsesScreen> createState() => _MyPulsesScreenState();
}

class _MyPulsesScreenState extends State<MyPulsesScreen> {
  final PulseService _pulseService = PulseService();
  List<Pulse> _myPulses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyPulses();
  }

  Future<void> _loadMyPulses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 사용자가 작성한 펄스만 필터링
      final allPulses = await _pulseService.getAllPulses();
      final myPulses =
          allPulses.where((pulse) => pulse.author == widget.userId).toList();

      if (mounted) {
        setState(() {
          _myPulses = myPulses;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('내 펄스 로드 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 작성한 펄스'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMyPulses),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _myPulses.isEmpty
              ? const Center(child: Text('작성한 펄스가 없습니다'))
              : RefreshIndicator(
                onRefresh: () async {
                  _loadMyPulses();
                },
                child: ListView.builder(
                  itemCount: _myPulses.length,
                  itemBuilder: (context, index) {
                    final pulse = _myPulses[index];
                    return PulseCard(pulse: pulse, onRefresh: _loadMyPulses);
                  },
                ),
              ),
    );
  }
}
