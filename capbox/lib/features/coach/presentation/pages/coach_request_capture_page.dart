import 'package:flutter/material.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';
import 'package:go_router/go_router.dart';

class CoachRequestCapturePage extends StatelessWidget {
  const CoachRequestCapturePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> alumnosPendientes = ['Jonathan Dzul Mendoza', 'Juan Jimenez'];

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/fondo.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(color: Colors.black.withOpacity(0.6)),
          SafeArea(
            child: Column(
              children: [
                const CoachHeader(),
                const Divider(color: Color.fromARGB(255, 75, 75, 75)),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Solicitud de captura de datos',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: alumnosPendientes.length,
                    itemBuilder: (context, index) {
                      final alumno = alumnosPendientes[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: GestureDetector(
                          onTap: () {
                            context.go('/coach/register-tutor');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.pink,
                                  child: Text('J', style: TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  alumno,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const CoachNavBar(currentIndex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
