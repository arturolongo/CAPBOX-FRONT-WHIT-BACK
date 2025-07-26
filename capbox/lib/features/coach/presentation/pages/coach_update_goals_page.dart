import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CoachUpdateGoalsPage extends StatefulWidget {
  const CoachUpdateGoalsPage({super.key});

  @override
  State<CoachUpdateGoalsPage> createState() => _CoachUpdateGoalsPageState();
}

class _CoachUpdateGoalsPageState extends State<CoachUpdateGoalsPage> {
  final List<String> goals = ['Mejorar postura'];
  final List<bool> completed = [true];
  final TextEditingController newGoalController = TextEditingController();
  final TextEditingController dayController = TextEditingController(text: '01');
  final TextEditingController monthController = TextEditingController(text: '07');
  final TextEditingController yearController = TextEditingController(text: '2025');

  void _addGoal() {
    final value = newGoalController.text.trim();
    if (value.isNotEmpty) {
      setState(() {
        goals.add(value);
        completed.add(false);
        newGoalController.clear();
      });
    }
  }

  bool _isValidDate() {
    final day = int.tryParse(dayController.text);
    final month = int.tryParse(monthController.text);
    final year = int.tryParse(yearController.text);
    if (day == null || month == null || year == null) return false;
    if (day < 1 || day > 31) return false;
    if (month < 1 || month > 12) return false;
    if (year < 2025 || year > 2030) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const CoachNavBar(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            const CoachHeader(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Crear rutina',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _studentInfoCard('Juan Jimenez', 'assets/images/profile_placeholder.png'),
                    const SizedBox(height: 10),
                    const Text('Editar fecha a cumplir', style: TextStyle(color: Colors.red, fontSize: 16)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _DateBox(controller: dayController, hint: 'DD'),
                        _DateBox(controller: monthController, hint: 'MM'),
                        _DateBox(controller: yearController, hint: 'AAAA'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Metas:', style: TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    for (int i = 0; i < goals.length; i++) _goalItem(goals[i], i),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: newGoalController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Añadir...',
                              hintStyle: const TextStyle(color: Colors.white38),
                              fillColor: Colors.grey[800],
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: _addGoal,
                          icon: const Icon(Icons.add, color: Colors.white),
                          color: Colors.green,
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_isValidDate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Metas actualizadas')),
                            );
                            context.go('/coach/student-profile');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Fecha inválida')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Actualizar metas'),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _goalItem(String text, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white)),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              completed[index] ? Icons.check_circle : Icons.circle_outlined,
              color: completed[index] ? Colors.green : Colors.white,
            ),
            onSelected: (value) {
              if (value == 'Completada') {
                setState(() => completed[index] = true);
              } else if (value == 'Eliminar') {
                setState(() {
                  goals.removeAt(index);
                  completed.removeAt(index);
                });
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Completada', child: Text('Completada')),
              PopupMenuItem(value: 'Eliminar', child: Text('Eliminar')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _studentInfoCard(String name, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(imagePath),
            radius: 20,
          ),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _DateBox({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: Colors.grey[900],
          contentPadding: const EdgeInsets.all(12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}