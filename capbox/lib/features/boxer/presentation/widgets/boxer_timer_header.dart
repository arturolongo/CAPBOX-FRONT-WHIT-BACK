import 'dart:ui';
import 'package:flutter/material.dart';

class BoxerTimerHeader extends StatelessWidget {
  final bool isRunning;
  final int remainingSeconds;
  final VoidCallback onToggle;
  final String? sessionTitle;

  const BoxerTimerHeader({
    super.key,
    required this.isRunning,
    required this.remainingSeconds,
    required this.onToggle,
    this.sessionTitle, 
  });

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'ENTRENAMIENTO',
          style: TextStyle(color: Colors.white, fontSize: 26),
        ),
        const SizedBox(height: 6),
        const Text(
          'TIMER',
          style: TextStyle(color: Colors.white70, fontSize: 22),
        ),
        const SizedBox(height: 12),
        Text(
          _formatTime(remainingSeconds),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 68,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onToggle,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.red,
            child: Icon(
              isRunning ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (sessionTitle != null) 
          Text(
            sessionTitle!,
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
      ],
    );
  }
}
