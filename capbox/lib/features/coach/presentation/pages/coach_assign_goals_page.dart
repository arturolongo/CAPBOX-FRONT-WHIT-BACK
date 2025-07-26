import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';

class CoachAssignGoalsPage extends StatefulWidget {
  const CoachAssignGoalsPage({super.key});

  @override
  State<CoachAssignGoalsPage> createState() => _CoachAssignGoalsPageState();
}

class _CoachAssignGoalsPageState extends State<CoachAssignGoalsPage> {
  final TextEditingController _goalController = TextEditingController();
  final List<String> _goals = [];
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  String selectedStudent = 'Juan Jimenez';
  Color buttonColor = const Color(0xFF0076AD);

  bool _isValidDate(String day, String month, String year) {
    final int? d = int.tryParse(day);
    final int? m = int.tryParse(month);
    final int? y = int.tryParse(year);
    if (d == null || m == null || y == null) return false;
    if (y > 2100 || y < 2000 || m < 1 || m > 12 || d < 1 || d > 31) return false;
    try {
      final date = DateTime(y, m, d);
      return date.day == d && date.month == m && date.year == y;
    } catch (_) {
      return false;
    }
  }

  void _addGoal(String goal) {
    if (goal.trim().isEmpty) return;
    setState(() {
      _goals.add(goal.trim());
      _goalController.clear();
    });
  }

  void _removeGoal(int index) {
    setState(() {
      _goals.removeAt(index);
    });
  }

  void _createGoals() {
    final day = _dayController.text;
    final month = _monthController.text;
    final year = _yearController.text;

    if (!_isValidDate(day, month, year)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey.shade900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Fecha no válida', style: TextStyle(color: Colors.white)),
          content: const Text('Introduce una fecha real y válida.', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      return;
    }

    if (_goals.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Metas creadas', style: TextStyle(color: Colors.white)),
        content: const Text('Se han creado las metas correctamente.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => context.go('/coach/home'),
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
      backgroundColor: Colors.black,
      bottomNavigationBar: const CoachNavBar(currentIndex: 1),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset('assets/images/fondo.png', fit: BoxFit.cover)),
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.6))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 80), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CoachHeader(),
                    const SizedBox(height: 20),
                    const Text('Crear rutina', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Alumno', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () async {
                            final selected = await context.push<String>('/coach/select-student');
                            if (selected != null) {
                              setState(() => selectedStudent = selected);
                            }
                          },
                          child: const Text('Seleccionar alumno', style: TextStyle(color: Color(0xFF0076AD))),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(radius: 16, backgroundColor: Colors.purple),
                          const SizedBox(width: 10),
                          Text(selectedStudent, style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Fecha a cumplir:', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildInputField(_dayController, 'Día')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildInputField(_monthController, 'Mes')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildInputField(_yearController, 'Año')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Metas:', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._goals.asMap().entries.map((entry) {
                      final index = entry.key;
                      final goal = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(goal, style: const TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _removeGoal(index),
                              child: const Icon(Icons.close, color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _goalController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Añadir...',
                              hintStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.grey.shade900,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onSubmitted: _addGoal,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () => _addGoal(_goalController.text),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _createGoals,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C864),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Crear metas', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.grey.shade900,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}