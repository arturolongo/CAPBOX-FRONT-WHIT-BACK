import 'package:flutter/material.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';
import 'package:go_router/go_router.dart';

class CoachStudentProfilePage extends StatelessWidget {
  final String studentName;

  const CoachStudentProfilePage({super.key, required this.studentName});

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
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CoachHeader(),
                  const SizedBox(height: 20),
                  const Text(
                    'Perfil de alumno',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.pink,
                          child: Text(
                            'J',
                            style: TextStyle(color: Colors.white, fontSize: 28),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                studentName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Principiante',
                                style: TextStyle(color: Colors.red),
                              ),
                              const Text(
                                '20 años | 70kg | 1.70m',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B0000),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text('5 días de racha'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004C99),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            context.go('/coach-ficha-tecnica', extra: {
                              'nombre': studentName,
                              'edad': 20,
                              'peso': '70kg',
                              'estatura': '1.70m',
                              'peleas': 25,
                              'victorias': 20,
                              'nivel': 'Principiante',
                              'guardia': 'Derecha',
                              'gimnasio': 'Zikar Palenque de campeones',
                              'entrenador': 'Fernando Dinamita',
                            });
                          },
                          child: const Text('Ver ficha técnica'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Metas asignadas',
                          style: TextStyle(color: Colors.white)),
                      Text('Fecha deseada: 01/07/2025',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('- 5km en 25 min',
                            style: TextStyle(color: Colors.white)),
                        Text('- 5kg abajo',
                            style: TextStyle(color: Colors.white)),
                        Text('- Mejorar guardia derecha',
                            style: TextStyle(color: Colors.white)),
                        Text('- Tratamiento lesión mano derecha',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004C99),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      context.go('/coach-update-goals');
                    },
                    child: const Text('Realizar check de metas'),
                  ),
                  const SizedBox(height: 16),
                  _grayButton('Ver métricas de rendimiento', onTap: () {
                    context.go('/coach-metrics');
                  }),
                  _grayButton('Realizar pruebas de rendimiento', onTap: () {
                    context.go('/coach/student-test-preview');
                  }),
                  _grayButton('Ver historial de peleas', onTap: () {
                    context.go('/coach/fights', extra: studentName);
                  }),
                  _grayButton('Registrar pelea(s)', onTap: () {
                    context.go('/coach-fight-register', extra: studentName);
                  }),
                  _grayButton('Editar datos personales / tutor / físicos', onTap: () {
                    context.go('/coach/edit-student');
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _grayButton(String text, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade800,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap ?? () {},
        child: Text(text),
      ),
    );
  }
}