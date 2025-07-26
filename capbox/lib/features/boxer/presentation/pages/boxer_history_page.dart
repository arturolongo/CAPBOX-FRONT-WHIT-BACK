import 'package:flutter/material.dart';
import '../widgets/boxer_header.dart';
import '../widgets/boxer_navbar.dart';

class BoxerHistoryPage extends StatefulWidget {
  const BoxerHistoryPage({super.key});

  @override
  State<BoxerHistoryPage> createState() => _BoxerHistoryPageState();
}

class _BoxerHistoryPageState extends State<BoxerHistoryPage> {
  final List<bool> _expanded = [false, false];

  final List<String> _sortOptions = [
    'Fecha más reciente',
    'Fecha más antigua',
    'Ganadas',
    'Perdidas',
    'Empates',
    'Campeonatos',
    'Demostraciones',
  ];

  String _selectedSort = 'Fecha más reciente';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const BoxerNavBar(currentIndex: 0),
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
                  const Text(
                    'Historial de peleas',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        'Ordenar por: ',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      DropdownButton<String>(
                        value: _selectedSort,
                        dropdownColor: Colors.black87,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        underline: const SizedBox(),
                        iconEnabledColor: Colors.red,
                        items: _sortOptions
                            .map((option) => DropdownMenuItem(
                                  value: option,
                                  child: Text(option, style: const TextStyle(color: Colors.red)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedSort = value;
                            });
                            // Aquí irá lo de la api
                          }
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFightCard(
                    index: 0,
                    title: 'Evento: Demostración',
                    place: 'Lugar: Gimnasio Zikar',
                    result: 'Resultado: Victoria',
                    date: '25/02/2025',
                  ),
                  const SizedBox(height: 12),
                  _buildFightCard(
                    index: 1,
                    title: 'Evento: Populares juvenil',
                    place: 'Lugar: Guadalajara',
                    result: 'Resultado: Victoria',
                    date: '25/02/2025',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFightCard({
    required int index,
    required String title,
    required String place,
    required String result,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _richTextLabel('Evento:', title.replaceFirst('Evento: ', '')),
                    _richTextLabel('Lugar:', place.replaceFirst('Lugar: ', '')),
                    _richTextLabel('Resultado:', result.replaceFirst('Resultado: ', '')),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(date, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              )
            ],
          ),
          if (_expanded[index]) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Datos del contrincante',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 4),
                  _richDetail('Nombre:', 'Arturo Amizaday Jimenez Ojendis'),
                  _richDetail('Edad:', '15 años   ', extraLabel: 'Peso:', extraValue: '55kg'),
                  _richDetail('Gimnasio:', 'Surimbox'),
                  _richDetail('Lugar del gimnasio:', 'Suchiapa'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Observaciones del entrenador:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Se cometieron 2 faltas y se realizaron 2 conteos, Juan no realizó ningún consejo dado en las esquinas.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _expanded[index] = !_expanded[index];
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF145374),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _expanded[index] ? 'Ver menos' : 'Ver más',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _richTextLabel(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _richDetail(String label, String value, {String? extraLabel, String? extraValue}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
          TextSpan(
            text: '$value',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if (extraLabel != null && extraValue != null) ...[
            TextSpan(
              text: '  $extraLabel ',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
            TextSpan(
              text: '$extraValue',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ]
        ],
      ),
    );
  }
}
