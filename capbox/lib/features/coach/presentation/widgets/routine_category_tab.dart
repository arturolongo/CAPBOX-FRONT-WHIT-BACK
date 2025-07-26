import 'package:flutter/material.dart';

class RoutineCategoryTab extends StatelessWidget {
  final String category;
  final List<Map<String, String>> exercises;
  final TextEditingController exerciseController;
  final TextEditingController minutesController;
  final TextEditingController secondsController;
  final void Function(String, String, String, String) onAdd;

  const RoutineCategoryTab({
    super.key,
    required this.category,
    required this.exercises,
    required this.exerciseController,
    required this.minutesController,
    required this.secondsController,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ejercicios añadidos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 3),
        SizedBox(
          height: 90,
          child: ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final ejercicio = exercises[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ejercicio['nombre']!,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      ejercicio['duracion']!,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const Divider(color: Colors.white24),
        const SizedBox(height: 10),
        const Text(
          'Añadir nuevo ejercicio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: exerciseController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Nombre del ejercicio',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.grey.shade900,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: minutesController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Minutos',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: secondsController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Segundos',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed: () {
              final nombre = exerciseController.text.trim();
              final min = minutesController.text.trim();
              final sec = secondsController.text.trim();
              if (nombre.isNotEmpty && min.isNotEmpty && sec.isNotEmpty) {
                onAdd(category, nombre, min, sec);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Añadir ejercicio', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
