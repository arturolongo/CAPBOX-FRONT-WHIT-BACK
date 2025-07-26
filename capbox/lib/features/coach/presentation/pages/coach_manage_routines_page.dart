import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';

class CoachManageRoutinesPage extends StatelessWidget {
  const CoachManageRoutinesPage({super.key});

  void _navigateToLevel(BuildContext context, String nivel) {
    context.go('/coach/manage/$nivel');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const CoachNavBar(currentIndex: 1),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/fondo.png', fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CoachHeader(),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  const Text(
                    'Gestionar rutinas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildStyledButton(context, 'Rutinas para avanzados', 'avanzado'),
                  _buildStyledButton(context, 'Rutinas para intermedios', 'intermedio'),
                  _buildStyledButton(context, 'Rutinas para principiantes', 'principiante'),
                  _buildStyledButton(context, 'Rutinas generales', 'general'),
                  const SizedBox(height: 30),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  _buildSolidButton(context, 'Crear rutina', () {
                    context.go('/coach/create-routine');
                  }),
                  const SizedBox(height: 12),
                  _buildSolidButton(context, 'Volver', () {
                    context.go('/coach-routines');
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledButton(BuildContext context, String label, String nivel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        height: 49,
        child: ElevatedButton(
          onPressed: () => _navigateToLevel(context, nivel),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 15, 253, 197).withOpacity(0.15),
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
          ),
        ),
      ),
    );
  }

  Widget _buildSolidButton(BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 41,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A5B4B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
        ),
      ),
    );
  }
}
