import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 👈 Import necesario
import 'package:capbox/features/coach/domain/entities/student_model.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_navbar.dart';

class AdminStudentProfilePage extends StatelessWidget {
  final Student student;

  const AdminStudentProfilePage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AdminNavBar(currentIndex: 1),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/fondo.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.65)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AdminHeader(),
                  const SizedBox(height: 12),
                  const Text(
                    'Perfil de alumno',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tarjeta del perfil
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.pink,
                          child: Text(
                            student.name[0],
                            style: const TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Algorítmico Jimenez',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                ),
                              ),
                              const Text(
                                'Principiante',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                              const Text(
                                '20 años | 70kg | 1.70m',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _styledButton(
                        context,
                        '5 días de racha',
                        '/racha',
                        color: Colors.red.shade900,
                      ),
                      const SizedBox(width: 8),
                      _styledButton(
                        context,
                        'Ver ficha técnica',
                        '/coach-ficha-tecnica',
                        color: Colors.blueGrey.shade900,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Datos de gimnasio
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Datos de miembro de gimnasio',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(color: Colors.white54),
                        const SizedBox(height: 6),
                        const Text(
                          'Inscrito desde: 03/09/2025',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const Text(
                          'Último pago de mensualidad: 10/08/2025',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const Text(
                          'Último pago de anualidad: 10/08/2024',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Pago mensual: \$150',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                            Text(
                              'Pago anual: \$150',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Asignar beca: 50%',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    () => context.go('/registrar-mensualidad'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Registrar mensualidad',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => context.go('/registrar-anualidad'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Registrar anualidad',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _grayButton(
                    context,
                    'Ver métricas de rendimiento',
                    '/coach-metrics',
                  ),
                  _grayButton(
                    context,
                    'Ver historial de peleas',
                    '/coach/fights',
                  ),
                  _grayButton(
                    context,
                    'Registrar pelea(s)',
                    '/coach-fight-register',
                  ),
                  _grayButton(
                    context,
                    'Editar datos personales / tutor / físicos',
                    '/coach/edit-student',
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.go('/eliminar-alumno'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB92D2D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size.fromHeight(45),
                    ),
                    child: const Text(
                      'ELIMINAR ALUMNO',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _styledButton(
    BuildContext context,
    String text,
    String route, {
    required Color color,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => context.go(route),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _grayButton(BuildContext context, String text, String route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.go(route),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size.fromHeight(45),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
