import 'package:flutter/material.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/routine_card_manage.dart';

class CoachManageRoutinePage extends StatefulWidget {
  final String nivel;
  const CoachManageRoutinePage({super.key, required this.nivel});

  @override
  State<CoachManageRoutinePage> createState() => _CoachManageRoutinePageState();
}

class _CoachManageRoutinePageState extends State<CoachManageRoutinePage> {
  int? expandedIndex;
  String selectedCategory = 'calentamiento';

  final List<Map<String, dynamic>> rutinas = [
    {
      'titulo': 'Rutina de ejemplo',
      'duracion': '25:00',
      'nivel': 'principiante',
      'ejercicios': 4,
      'categorias': {
        'calentamiento': [
          {'nombre': 'Saco pesado', 'duracion': '10 minutos'},
        ],
        'resistencia': [
          {'nombre': 'Burpees', 'duracion': '10 minutos'},
        ],
        'tecnica': [
          {'nombre': 'Guardia', 'duracion': '8 minutos'},
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
              child: Image.asset('assets/images/fondo.png', fit: BoxFit.cover),
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
                    'Gestionar rutinas - ${widget.nivel}',
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
                      itemBuilder: (context, index) => RoutineCardManage(
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
