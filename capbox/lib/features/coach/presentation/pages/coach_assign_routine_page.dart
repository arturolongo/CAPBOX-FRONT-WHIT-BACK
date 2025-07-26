import 'package:capbox/features/coach/presentation/widgets/routine_card.dart';
import 'package:flutter/material.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';

class CoachAssignRoutinePage extends StatefulWidget {
  final String nivel;
  const CoachAssignRoutinePage({super.key, required this.nivel});

  @override
  State<CoachAssignRoutinePage> createState() => _CoachAssignRoutinePageState();
}

class _CoachAssignRoutinePageState extends State<CoachAssignRoutinePage> {
  int? expandedIndex;
  String selectedCategory = 'calentamiento';

  final List<Map<String, dynamic>> rutinas = [
    {
      'titulo': 'Rutina para mejorar velocidad',
      'duracion': '25:00',
      'nivel': 'principiante',
      'ejercicios': 4,
      'categorias': {
        'calentamiento': [
          {'nombre': 'Saco pesado', 'duracion': '10 minutos'},
          {'nombre': 'Manoplas', 'duracion': '5 minutos'},
          {'nombre': 'Reflejos', 'duracion': '10 minutos'},
        ],
        'resistencia': [
          {'nombre': 'Burpees', 'duracion': '10 minutos'},
          {'nombre': 'Saltos', 'duracion': '5 minutos'},
        ],
        'tecnica': [
          {'nombre': 'Guardia', 'duracion': '8 minutos'},
          {'nombre': 'Combinaciones', 'duracion': '12 minutos'},
        ],
      },
    },
    {
      'titulo': 'Rutina golpes y saltos',
      'duracion': '25:00',
      'nivel': 'principiante',
      'ejercicios': 4,
      'categorias': {
        'calentamiento': [
          {'nombre': 'Saltar la cuerda', 'duracion': '5 minutos'},
        ],
        'resistencia': [
          {'nombre': 'Golpes al saco', 'duracion': '10 minutos'},
        ],
        'tecnica': [
          {'nombre': 'Combinaciones', 'duracion': '10 minutos'},
        ],
      },
    },
    {
      'titulo': 'Rutina de golpes rápidos',
      'duracion': '1:00:00',
      'nivel': 'principiante',
      'ejercicios': 10,
      'categorias': {
        'calentamiento': [
          {'nombre': 'Sombras', 'duracion': '10 minutos'},
        ],
        'resistencia': [
          {'nombre': 'Golpes rápidos', 'duracion': '20 minutos'},
        ],
        'tecnica': [
          {'nombre': 'Combinaciones avanzadas', 'duracion': '30 minutos'},
        ],
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const CoachNavBar(currentIndex: 1),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/fondo.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CoachHeader(),
                  const SizedBox(height: 20),
                  Text(
                    'Asignar rutinas - ${widget.nivel}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: rutinas.length,
                      itemBuilder: (context, index) => RoutineCard(
                        rutina: rutinas[index],
                        nivel: widget.nivel,
                        index: index,
                        expandedIndex: expandedIndex,
                        selectedCategory: selectedCategory,
                        onExpand: (newIndex) {
                          setState(() {
                            expandedIndex = newIndex;
                            selectedCategory = 'calentamiento';
                          });
                        },
                        onCategoryChange: (newCategory) {
                          setState(() => selectedCategory = newCategory);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}