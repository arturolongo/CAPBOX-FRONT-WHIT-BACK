import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';
import 'package:capbox/features/coach/presentation/widgets/routine_category_tab.dart';

class CoachCreateRoutinePage extends StatefulWidget {
  const CoachCreateRoutinePage({super.key});

  @override
  State<CoachCreateRoutinePage> createState() => _CoachCreateRoutinePageState();
}

class _CoachCreateRoutinePageState extends State<CoachCreateRoutinePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _exerciseController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();

  String selectedLevel = 'Principiante';
  String activeCategory = 'calentamiento';

  final Map<String, List<Map<String, String>>> ejercicios = {
    'calentamiento': [],
    'resistencia': [],
    'tecnica': [],
  };

  void _addExerciseToCategory(String category, String nombre, String minutos, String segundos) {
    setState(() {
      ejercicios[category]?.add({
        'nombre': nombre,
        'duracion': '$minutos:$segundos',
      });
    });

    _exerciseController.clear();
    _minutesController.clear();
    _secondsController.clear();
  }

  void _crearRutina() {
    if (_nameController.text.isEmpty || ejercicios.values.every((e) => e.isEmpty)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Campos obligatorios', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Por favor, completa todos los campos y añade al menos un ejercicio.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar', style: TextStyle(color: Colors.red)),
            )
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Rutina creada', style: TextStyle(color: Colors.white)),
        content: const Text(
          'La rutina se ha guardado correctamente.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.go('/coach-home');
            },
            child: const Text('Ir al inicio', style: TextStyle(color: Colors.green)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
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
          Column(
            children: [
              const SafeArea(child: CoachHeader()),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Crear rutina',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _formContent(),
                ),
              ),
              const CoachNavBar(currentIndex: 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _formContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Nombre de la rutina',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.grey.shade900,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: selectedLevel,
          dropdownColor: Colors.grey.shade900,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade900,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: ['Principiante', 'Intermedio', 'Avanzado', 'General']
              .map((nivel) => DropdownMenuItem(
                    value: nivel,
                    child: Text(nivel, style: const TextStyle(color: Colors.white)),
                  ))
              .toList(),
          onChanged: (value) => setState(() => selectedLevel = value ?? 'Principiante'),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['calentamiento', 'resistencia', 'tecnica'].map((cat) {
            final selected = activeCategory == cat;
            return GestureDetector(
              onTap: () => setState(() => activeCategory = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: selected ? Colors.red : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  cat[0].toUpperCase() + cat.substring(1),
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        RoutineCategoryTab(
          category: activeCategory,
          exercises: ejercicios[activeCategory]!,
          exerciseController: _exerciseController,
          minutesController: _minutesController,
          secondsController: _secondsController,
          onAdd: _addExerciseToCategory,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed: _crearRutina,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Crear rutina', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}