import 'package:flutter/material.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';

class CoachRankingSparringsPage extends StatefulWidget {
  const CoachRankingSparringsPage({super.key});

  @override
  State<CoachRankingSparringsPage> createState() => _CoachRankingSparringsPageState();
}

class _CoachRankingSparringsPageState extends State<CoachRankingSparringsPage> {
  String selectedNivel = 'Todos';
  final List<String> niveles = ['Todos', 'Principiante', 'Intermedio', 'Avanzado'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              color: Colors.black.withOpacity(0.5),
            ),
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
                    'Ver mejores sparrings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Mostrar:',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: selectedNivel,
                        dropdownColor: Colors.grey.shade900,
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        items: niveles.map((nivel) {
                          return DropdownMenuItem<String>(
                            value: nivel,
                            child: Text(nivel),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedNivel = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _RankingCard(rank: 1),
                  const _RankingCard(rank: 2),
                  const _RankingCard(rank: 3),
                  const _RankingCard(rank: 4),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final int rank;
  const _RankingCard({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.pink,
                child: Text('J', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Nuricumbo Jimenez Pedregal',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'Ranking #$rank',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _Metric(label: 'Resistencia', value: '8.9', color: Colors.green),
              _Metric(label: 'Velocidad', value: '7.5', color: Colors.yellow),
              _Metric(label: 'Técnica', value: '9', color: Colors.green),
              _Metric(label: 'Fuerza', value: '5', color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: const TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}