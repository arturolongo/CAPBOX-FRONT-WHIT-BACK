import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';
import 'package:flutter/material.dart';

class CoachFightHistoryPage extends StatefulWidget {
  final String studentName;

  const CoachFightHistoryPage({super.key, required this.studentName});

  @override
  State<CoachFightHistoryPage> createState() => _CoachFightHistoryPageState();
}

class _CoachFightHistoryPageState extends State<CoachFightHistoryPage> {
  bool sortByRecent = true;
  final List<Map<String, dynamic>> fightHistory = [
    {
      'event': 'Demostración',
      'place': 'Gimnasio Zikar',
      'result': 'Victoria',
      'opponent': {
        'name': 'Arturo Amizaday Jimenez Ojendis',
        'age': '15 años',
        'weight': '55kg',
        'gym': 'Surimbox',
        'gymLocation': 'Suchiapa',
      },
      'observations':
          'Se cometieron 2 faltas y se realizaron 2 conteos, Juan no realizó ningún consejo dado en las esquinas',
      'date': DateTime(2025, 2, 25),
    },
    {
      'event': 'Populares juveniles',
      'place': 'Guadalajara',
      'result': 'Victoria',
      'date': DateTime(2025, 2, 25),
    },
  ];

  List<bool> expanded = [];

  @override
  void initState() {
    super.initState();
    expanded = List.generate(fightHistory.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    final sortedFights = List<Map<String, dynamic>>.from(fightHistory);
    sortedFights.sort((a, b) => sortByRecent
        ? b['date'].compareTo(a['date'])
        : a['date'].compareTo(b['date']));

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const CoachHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView(
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      'Historial de peleas',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Ordenar por:',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<bool>(
                          dropdownColor: Colors.black,
                          value: sortByRecent,
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Text(
                                'Fecha más reciente',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text(
                                'Fecha más antigua',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              sortByRecent = value!;
                            });
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...sortedFights.asMap().entries.map((entry) {
                      final index = entry.key;
                      final fight = entry.value;
                      final showFull = expanded[index];
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                expanded[index] = !expanded[index];
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nombre: ${widget.studentName}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Evento: ${fight['event']}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  Text(
                                    'Lugar: ${fight['place']}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  Text(
                                    'Resultado: ${fight['result']}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '${fight['date'].day.toString().padLeft(2, '0')}/${fight['date'].month.toString().padLeft(2, '0')}/${fight['date'].year}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  if (showFull && fight['opponent'] != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Datos del contrincante',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[800],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Nombre: ${fight['opponent']['name']}',
                                                style: const TextStyle(
                                                    color: Colors.red),
                                              ),
                                              Text(
                                                'Edad: ${fight['opponent']['age']}',
                                                style: const TextStyle(
                                                    color: Colors.red),
                                              ),
                                              Text(
                                                'Peso: ${fight['opponent']['weight']}',
                                                style: const TextStyle(
                                                    color: Colors.red),
                                              ),
                                              Text(
                                                'Gimnasio: ${fight['opponent']['gym']}',
                                                style: const TextStyle(
                                                    color: Colors.red),
                                              ),
                                              Text(
                                                'Lugar del gimnasio: ${fight['opponent']['gymLocation']}',
                                                style: const TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Observaciones del entrenador:',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[800],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            fight['observations'],
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        )
                                      ],
                                    )
                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: const CoachNavBar(currentIndex: 1),
    );
  }
}