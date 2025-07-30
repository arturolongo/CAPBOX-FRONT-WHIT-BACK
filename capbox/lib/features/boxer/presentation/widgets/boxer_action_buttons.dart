import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'boxer_streak_display.dart';

class BoxerActionButtons extends StatelessWidget {
  const BoxerActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Racha real del atleta
        const BoxerStreakDisplay(),
        const SizedBox(height: 12),

        // Botón de ficha técnica
        _buildActionButton(
          context: context,
          text: 'Ver ficha técnica',
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.lightBlue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          onTap: () {
            // Navegar a la ficha técnica
            context.push('/boxer-technical-sheet');
          },
        ),
        const SizedBox(height: 12),

        // Botón de métricas de rendimiento
        _buildActionButton(
          context: context,
          text: 'Ver métricas de rendimiento',
          backgroundColor: Colors.grey[800],
          onTap: () {
            // Navegar a métricas de rendimiento
            context.push('/boxer-performance');
          },
        ),
        const SizedBox(height: 12),

        // Botón de historial de peleas
        _buildActionButton(
          context: context,
          text: 'Historial de peleas',
          backgroundColor: Colors.grey[800],
          onTap: () {
            // Navegar a historial de peleas
            context.push('/boxer-fight-history');
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String text,
    LinearGradient? gradient,
    Color? backgroundColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: gradient,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
