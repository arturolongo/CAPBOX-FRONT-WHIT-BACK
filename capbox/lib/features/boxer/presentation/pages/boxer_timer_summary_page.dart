import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/boxer_navbar.dart';
import '../widgets/boxer_timer_header.dart';
import '../widgets/boxer_timer_table.dart';
import '../widgets/boxer_timer_actions.dart';

class BoxerTimerSummaryPage extends StatefulWidget {
  const BoxerTimerSummaryPage({super.key});

  @override
  State<BoxerTimerSummaryPage> createState() => _BoxerTimerSummaryPageState();
}

class _BoxerTimerSummaryPageState extends State<BoxerTimerSummaryPage> {
  late int remainingSeconds;
  Timer? _timer;
  bool isRunning = false;

  final List<Map<String, String>> exercises = [
    {'name': 'Burpees', 'count': '50'},
    {'name': 'Flexiones de pecho', 'count': '50'},
    {'name': 'Sentadillas', 'count': '50'},
    {'name': 'Abdominales', 'count': '50'},
  ];

  @override
  void initState() {
    super.initState();
    remainingSeconds = 90;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          isRunning = false;
        });
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
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
                  isRunning: isRunning,
                  remainingSeconds: remainingSeconds,
                  onToggle: _toggleTimer,
                  sessionTitle: 'SESIÓN DE RESISTENCIA',
                ),
                const SizedBox(height: 24),
                BoxerTimerTable(exercises: exercises),
                const SizedBox(height: 24),
                BoxerTimerActions(
                  onRetirarse: () => context.go('/boxer-home'),
                  onCompletado: () => context.go('/technique'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

