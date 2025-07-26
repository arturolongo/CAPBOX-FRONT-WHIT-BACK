import 'package:flutter/material.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';

class CoachRankingPage extends StatefulWidget {
  const CoachRankingPage({super.key});

  @override
  State<CoachRankingPage> createState() => _CoachRankingPageState();
}

class _CoachRankingPageState extends State<CoachRankingPage> {
  final List<String> boxeadores = [
    'Arturo Amizaday Jimenez Ojendis',
    'Nuricumbo Jimenez Pedregal',
    'Alberto Taboada De La Cruz',
  ];

  final List<String> rivalesOptimos = [
    'Ana Karen Álvarez Borralles',
    'Juan Jimenez',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CoachNavBar(currentIndex: 1),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/fondo.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CoachHeader(),
                  const SizedBox(height: 16),
                  const Text(
                    'Ranking de boxeadores',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBoxeadorConRivales('Arturo Amizaday Jimenez Ojendis', rivalesOptimos),
                  const SizedBox(height: 8),
                  ...boxeadores
                      .skip(1)
                      .map((nombre) => _buildCard(nombre))
                      .toList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxeadorConRivales(String nombre, List<String> rivales) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(nombre),
          const Divider(color: Colors.red),
          const Text(
            'Rivales mas óptimos:',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...rivales.map((rival) => _buildCard(rival, mini: true)).toList(),
        ],
      ),
    );
  }

  Widget _buildCard(String nombre, {bool mini = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: mini ? Colors.grey.shade700 : Colors.grey.shade800.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.pink,
            child: Text('J', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nombre,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}