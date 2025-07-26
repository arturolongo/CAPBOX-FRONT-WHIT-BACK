import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/boxer_navbar.dart';
import '../widgets/boxer_timer_header.dart';
import '../widgets/boxer_timer_table.dart';
import '../widgets/boxer_timer_actions.dart';

class BoxerTechniquePage extends StatefulWidget {
  const BoxerTechniquePage({super.key});

  @override
  State<BoxerTechniquePage> createState() => _BoxerTechniquePageState();
}

class _BoxerTechniquePageState extends State<BoxerTechniquePage> {
  final List<Map<String, String>> exercises = [
    {'name': 'Saco pesado', 'count': '4 rounds'},
    {'name': 'Manoplas', 'count': '5 minutos'},
    {'name': 'Reflejos', 'count': '10 minutos'},
  ];

  late int remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    remainingSeconds = 85; 
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
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        timer.cancel();
        setState(() => _isRunning = false);
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
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
                  sessionTitle: 'SESIÓN DE TÉCNICA',
                ),
                const SizedBox(height: 24),
                BoxerTimerTable(exercises: exercises),
                const SizedBox(height: 24),
                BoxerTimerActions(
                  onRetirarse: () => context.go('/boxer-home'),
                  onCompletado: () => context.go('/summary'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}