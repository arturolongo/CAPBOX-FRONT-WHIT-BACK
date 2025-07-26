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
      ],
    );
  }
}
