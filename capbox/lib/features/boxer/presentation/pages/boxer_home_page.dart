import 'package:flutter/material.dart';
import '../widgets/boxer_header.dart';
import '../widgets/boxer_streak_goals.dart';
import '../widgets/boxer_exercises.dart';
import '../widgets/boxer_navbar.dart';

class BoxerHomePage extends StatelessWidget {
  const BoxerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: BoxerNavBar(currentIndex: 1),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/fondo.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(.6)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoxerHeader(),
                  SizedBox(height: 12),
                  BoxerStreakGoals(),
                  SizedBox(height: 16),
                  BoxerExercises(),
                  SizedBox(height: 40),   
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
