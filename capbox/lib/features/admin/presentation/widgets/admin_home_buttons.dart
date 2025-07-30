import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'admin_button.dart';

class AdminHomeButtons extends StatelessWidget {
  const AdminHomeButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdminButton(
          label: 'Lista de asistencia',
          color: const Color(0xFF008E76),
          onPressed: () {
            context.go('/admin-attendance');
          },
        ),
        const SizedBox(height: 16),
        const Divider(color: Color.fromARGB(255, 110, 109, 109)),
        const SizedBox(height: 16),
        AdminButton(
          label: 'Gestionar alumnos',
          color: const Color(0xFF0076AD),
          onPressed: () {
            context.go('/admin-manage-students');
          },
        ),
        const SizedBox(height: 16),
        AdminButton(
          label: 'Gestionar clave del gimnasio',
          color: const Color(0xFFFF0909),
          onPressed: () {
            context.go('/admin/gym-key');
          },
        ),
        const SizedBox(height: 16),
        AdminButton(
          label: 'Vincular a gimnasio',
          color: const Color(0xFF8B4513),
          onPressed: () {
            _showGymKeyDialog(context);
          },
        ),
        const SizedBox(height: 16),
        AdminButton(
          label: '🔍 Debug - Miembros',
          color: const Color(0xFF9C27B0),
          onPressed: () {
            context.go('/admin-debug-members');
          },
        ),
      ],
    );
  }
}

void _showGymKeyDialog(BuildContext context) {
  final TextEditingController keyController = TextEditingController();

  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text(
            'Vincular a Gimnasio',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ingresa la clave del gimnasio para vincular tu cuenta:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: keyController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Clave del gimnasio',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final key = keyController.text.trim();
                if (key.isNotEmpty) {
                  Navigator.pop(context);
                  _linkToGym(context, key);
                }
              },
              child: const Text('Vincular'),
            ),
          ],
        ),
  );
}

void _linkToGym(BuildContext context, String gymKey) async {
  try {
    // Aquí usaríamos el cubit para vincular
    // Por ahora solo mostraremos un mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vinculando con clave: $gymKey'),
        backgroundColor: Colors.orange,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
    );
  }
}
