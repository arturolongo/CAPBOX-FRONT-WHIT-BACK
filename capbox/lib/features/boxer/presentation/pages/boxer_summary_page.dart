import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BoxerSummaryPage extends StatelessWidget {
  const BoxerSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // valores que después vendrán de la base de datos
    final totalTime = '01:20:20';
    final goalTime = '1:10:00';
    final calentamientoTime = '00:15:10';
    final resistenciaTime = '00:30:00';
    final tecnicaTime = '00:35:10';

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const _BottomNavBar(),
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
                const Text(
                  'ENTRENAMIENTO',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(height: 24),
                const Text(
                  'EJERCICIOS TERMINADOS',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tiempo total',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  totalTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 68,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Meta: $goalTime',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Tiempo por sesión',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                _SessionRow(icon: 'calentamiento', label: 'Calentamiento', time: calentamientoTime),
                _SessionRow(icon: 'resistencia', label: 'Resistencia', time: resistenciaTime),
                _SessionRow(icon: 'tecnica', label: 'Técnica', time: tecnicaTime),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/boxer-home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Guardar y salir', style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final String icon;
  final String label;
  final String time;

  const _SessionRow({
    required this.icon,
    required this.label,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset('assets/icons/$icon.png', height: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
          Text(time, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.white70,
      currentIndex: 1,
      onTap: (index) {
        if (index == 0) context.go('/boxer-events');
        if (index == 1) context.go('/boxer-home');
        if (index == 2) context.go('/boxer-profile');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.sports_mma), label: 'Entrenamiento'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}