import 'package:flutter/material.dart';
import '../widgets/boxer_header.dart';
import '../widgets/boxer_navbar.dart';
import '../widgets/boxer_metrics_chart.dart';
import '../widgets/boxer_metrics_list.dart';
import '../widgets/boxer_metrics_detailed_chart.dart';
import '../widgets/boxer_metrics_detailed_list.dart'; 

class BoxerMetricsPage extends StatefulWidget {
  const BoxerMetricsPage({super.key});

  @override
  State<BoxerMetricsPage> createState() => _BoxerMetricsPageState();
}

class _BoxerMetricsPageState extends State<BoxerMetricsPage> {
  bool showChart = true;
  bool showDetailed = false;

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
                  const SizedBox(height: 18),
                  const Text(
                    'Gráficas de datos obtenidos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Alumno:',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _studentCard(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showChart = false;
                              showDetailed = false;
                            });
                          },
                          child: _pillButton('Calificación'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showChart = true;
                              showDetailed = false;
                            });
                          },
                          child: _pillButton('Gráficos'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showDetailed = !showDetailed;
                      });
                    },
                    child: _bigAction(showDetailed ? 'Ver vista general' : 'Ver vista detallada'),
                  ),
                  const SizedBox(height: 16),
                  _buildContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (showDetailed) {
      if (showChart) {
        // gráfica roja
        return const BoxerMetricsDetailedChart();
      } else {
        // tabla detallada 
        return const BoxerMetricsDetailedList();
      }
    } else {
      if (showChart) {
        // gráfica azul
        return const BoxerMetricsChart();
      } else {
        // lista simple
        return const BoxerMetricsList();
      }
    }
  }

  Widget _studentCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFC31A7B),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                'J',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Juan Juanito Jimenez Mendoza',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                  Text(
                    'Principiante',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  Text(
                    '20 años │ 70 kg │ 1.70m',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            )
          ],
        ),
      );

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

  Widget _bigAction(String text) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
}
