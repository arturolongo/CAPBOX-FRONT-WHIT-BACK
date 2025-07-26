import 'package:flutter/material.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_home_content.dart';

class CoachHomePage extends StatelessWidget {
  const CoachHomePage({super.key});

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
          const SafeArea(
            child: CoachHomeContent(),
          ),
        ],
      ),
    );
  }
}
