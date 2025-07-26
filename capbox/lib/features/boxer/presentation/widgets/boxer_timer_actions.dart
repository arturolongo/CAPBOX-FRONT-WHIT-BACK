import 'package:flutter/material.dart';

class BoxerTimerActions extends StatelessWidget {
  final VoidCallback onRetirarse;
  final VoidCallback onCompletado;

  const BoxerTimerActions({
    super.key,
    required this.onRetirarse,
    required this.onCompletado,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE0000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: onRetirarse,
              child: const Text('Retirarse',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF096D02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: onCompletado,
              child: const Text('Completado',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}