import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/coach_header.dart';
import '../widgets/coach_navbar.dart';

class CoachPerformanceTest2Page extends StatefulWidget {
  const CoachPerformanceTest2Page({super.key});

  @override
  State<CoachPerformanceTest2Page> createState() => _CoachPerformanceTest2PageState();
}

class _CoachPerformanceTest2PageState extends State<CoachPerformanceTest2Page> {
  final TextEditingController _resultController = TextEditingController();

  @override
  void dispose() {
    _resultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const CoachNavBar(currentIndex: 1),
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
                  const CoachHeader(),
                  const SizedBox(height: 20),
                  _studentInfoCard(),
                  const SizedBox(height: 20),
                  const Text(
                    'Captura de pruebas de rendimiento',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _alertBox(),
                  const SizedBox(height: 12),
                  const Text(
                    'Prueba 2 de 8',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  _pill('Combinación 1-2-3'),
                  const SizedBox(height: 16),
                  const Text(
                    'Instrucciones para realizar la prueba',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _instructionBox(),
                  const SizedBox(height: 24),
                  const Text(
                    'Resultados de prueba',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  _resultInput(),
                  const SizedBox(height: 4),
                  const Text(
                    '(tiempo en que terminó las 3 series)',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  _continueButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text(
              'J',
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Juan Jimenez',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Principiante',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
                Text(
                  '20 años │ 70kg │ 1.70m',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _alertBox() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFFFB800),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'ATENCIÓN!\nEsta encuesta debe realizarse con exactitud siguiendo las recomendaciones dadas. '
          'La toma de estas pruebas será crucial para realizar predicciones con la inteligencia artificial.',
          style: TextStyle(color: Colors.black, fontSize: 13),
        ),
      );

  Widget _pill(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0478AE), Color(0xFF023E5C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      );

  Widget _instructionBox() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Con cronómetro registre cuanto tiempo le toma al alumno ejecutar 10 series de combinación:\n'
          'jab - recto - ganchod',
          style: TextStyle(color: Colors.white70),
        ),
      );

  Widget _resultInput() => TextField(
        controller: _resultController,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Ingresa tiempo en segundos...',
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: Colors.white12,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      );

  Widget _continueButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_resultController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor ingresa un resultado')),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guardado correctamente')),
        );
        context.go('/coach-performance-test-3');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Guardar y continuar', style: TextStyle(color: Colors.white)),
    );
  }
}