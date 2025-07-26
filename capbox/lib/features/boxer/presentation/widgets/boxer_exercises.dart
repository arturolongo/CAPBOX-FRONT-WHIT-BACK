import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 

class BoxerExercises extends StatelessWidget {
  const BoxerExercises({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Ejercicios de hoy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Icon(Icons.timer, color: Colors.white, size: 17),
            SizedBox(width: 4),
            Text('1:10:00', style: TextStyle(color: Colors.yellow, fontSize: 15)),
            SizedBox(width: 8),
            Icon(Icons.flag, color: Colors.white, size: 17),
            SizedBox(width: 4),
            Text('40:00', style: TextStyle(color: Colors.green, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 18),
        _buildExerciseCard('Calentamiento', 'assets/icons/calentamiento.png'),
        const SizedBox(height: 18),
        _buildExerciseCard('Resistencia', 'assets/icons/resistencia.png'),
        const SizedBox(height: 18),
        _buildExerciseCard('Técnica', 'assets/icons/tecnica.png'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'Iniciar entrenamiento',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                context.go('/timer'); 
              },
              child: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.play_arrow, color: Colors.white),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildExerciseCard(String title, String iconPath) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(iconPath, height: 30),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          const Icon(Icons.timer, color: Colors.white, size: 17),
          const SizedBox(width: 4),
          const Text('3:15', style: TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(width: 4),
          const Icon(Icons.flag, color: Colors.white, size: 17),
          const SizedBox(width: 4),
          const Text('3:00', style: TextStyle(color: Colors.white70, fontSize: 15)),
        ],
      ),
    );
  }
}