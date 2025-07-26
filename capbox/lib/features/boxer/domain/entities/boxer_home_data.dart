import 'package:capbox/features/boxer/presentation/widgets/boxer_events.dart';
import 'package:capbox/features/boxer/presentation/widgets/boxer_exercises.dart';
import 'package:capbox/features/boxer/presentation/widgets/boxer_header.dart';
import 'package:capbox/features/boxer/presentation/widgets/boxer_streak_goals.dart';
import 'package:flutter/material.dart';

class BoxerHomePage extends StatelessWidget {
  const BoxerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: _buildBottomBar(),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  BoxerHeader(),
                  SizedBox(height: 12),
                  BoxerStreakGoals(),
                  SizedBox(height: 16),
                  BoxerExercises(),
                  SizedBox(height: 16),
                  BoxerEvents(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.white,
      currentIndex: 1,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}