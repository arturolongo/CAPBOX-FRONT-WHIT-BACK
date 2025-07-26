import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/boxer_navbar.dart';
import '../widgets/boxer_timer_header.dart';
import '../widgets/boxer_timer_table.dart';
import '../widgets/boxer_timer_actions.dart';

class BoxerTimerPage extends StatefulWidget {
  final int durationSeconds;

  const BoxerTimerPage({super.key, this.durationSeconds = 90});

  @override
  State<BoxerTimerPage> createState() => _BoxerTimerPageState();
}

class _BoxerTimerPageState extends State<BoxerTimerPage> {
  final List<Map<String, String>> exercises = [
    {'name': 'Movimientos de hombro', 'count': '30'},
    {'name': 'Movimientos de cabeza', 'count': '30'},
    {'name': 'Estiramientos de brazos', 'count': '30'},
    {'name': 'Movimientos de pies', 'count': '1min'},
  ];

  late int remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.durationSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isRunning = false;
        });
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const BoxerNavBar(currentIndex: 1),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/fondo.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.6)),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BoxerTimerHeader(
                  isRunning: _isRunning,
                  remainingSeconds: remainingSeconds,
                  onToggle: _toggleTimer,
                  sessionTitle: 'SESIÓN DE CALENTAMIENTO', 
                ),
                const SizedBox(height: 24),
                BoxerTimerTable(exercises: exercises),
                const SizedBox(height: 24),
                BoxerTimerActions(
                  onRetirarse: () => context.go('/boxer-home'),
                  onCompletado: () => context.go('/timer-summary'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
