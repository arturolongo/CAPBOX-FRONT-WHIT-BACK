import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/coach_header.dart';
import '../widgets/coach_navbar.dart';

class CoachRoutinesPage extends StatelessWidget {
  const CoachRoutinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const CoachNavBar(currentIndex: 1),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CoachHeader(),
                  const SizedBox(height: 24),
                  const Text(
                    'Asignar rutinas',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _RoutineButton(
                    text: 'Asignar a avanzados',
                    nivel: 'avanzado',
                  ),
                  const SizedBox(height: 12),
                  _RoutineButton(
                    text: 'Asignar a intermedios',
                    nivel: 'intermedio',
                  ),
                  const SizedBox(height: 12),
                  _RoutineButton(
                    text: 'Asignar a principiantes',
                    nivel: 'principiante',
                  ),
                  const SizedBox(height: 12),
                  _RoutineButton(
                    text: 'Asignar rutina general',
                    nivel: 'general',
                  ),
                  const SizedBox(height: 36),
                  const _RoutineButton(
                    text: 'Gestionar rutinas',
                    color: Color(0xFF006F38),
                    isGestionar: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutineButton extends StatelessWidget {
  final String text;
  final String? nivel;
  final Color color;
  final bool isGestionar;

  const _RoutineButton({
    required this.text,
    this.nivel,
    this.color = const Color.fromRGBO(113, 113, 113, 0.5),
    this.isGestionar = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: () {
          if (isGestionar) {
            context.go('/coach/manage-routines');
            return;
          }
          if (nivel != null) {
            context.push('/assign-routine/$nivel');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}