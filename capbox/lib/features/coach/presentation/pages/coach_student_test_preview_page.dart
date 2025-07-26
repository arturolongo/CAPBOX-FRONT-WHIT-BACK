import 'package:flutter/material.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

class CoachStudentTestPreviewPage extends StatelessWidget {
  const CoachStudentTestPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const CoachNavBar(currentIndex: 1),
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
                children: [
                  const CoachHeader(),
                  const SizedBox(height: 10),
                  const Text(
                    'Alumno a realizar pruebas:',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  _studentCard(),
                  const SizedBox(height: 12),
                  const Text(
                    'Última fecha de toma de pruebas:',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '02/02/2025',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      context.go('/coach/student-test');
                    },
                    child: const Text('REALIZAR PRUEBAS'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Últimos resultados:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _pillButton('Calificación')),
                      const SizedBox(width: 12),
                      Expanded(child: _pillButton('Gráficos')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _grayButton('Ver vista detallada'),
                  const SizedBox(height: 20),
                  _buildRadarChart(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/boxer.png', 
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Arturo Amizaday Jimenez Ojendis',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
                Text(
                  '20 años | 70kg | 1.70m',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _pillButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0478AE), Color(0xFF023E5C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _grayButton(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildRadarChart() {
    final metrics = {
      'Resistencia': 8.0,
      'Velocidad': 6.5,
      'Técnica': 7.8,
      'Fuerza': 5.0,
    };

    return SizedBox(
      height: 300,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          radarBackgroundColor: Colors.transparent,
          gridBorderData: const BorderSide(color: Colors.white24),
          tickBorderData: const BorderSide(color: Colors.white24),
          titlePositionPercentageOffset: 0.2,
          tickCount: 5,
          ticksTextStyle: const TextStyle(color: Colors.white70, fontSize: 10),
          dataSets: [
            RadarDataSet(
              fillColor: Colors.blue.withOpacity(0.4),
              borderColor: Colors.blue,
              entryRadius: 3,
              borderWidth: 2,
              dataEntries:
                  metrics.values.map((v) => RadarEntry(value: v)).toList(),
            ),
          ],
          getTitle: (index, _) => RadarChartTitle(
            text: metrics.keys.elementAt(index),
          ),
        ),
      ),
    );
  }
}