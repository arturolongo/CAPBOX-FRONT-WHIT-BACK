import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/boxer_header.dart';
import '../widgets/boxer_navbar.dart';
import '../widgets/boxer_athlete_profile.dart';
import '../widgets/boxer_action_buttons.dart';

class BoxerProfilePage extends StatelessWidget {
  const BoxerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const BoxerNavBar(currentIndex: 2),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BoxerHeader(),
                  const SizedBox(height: 16),

                  // Perfil del atleta con datos reales
                  const BoxerAthleteProfile(),
                  const SizedBox(height: 20),

                  // Botones de acción
                  const BoxerActionButtons(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
