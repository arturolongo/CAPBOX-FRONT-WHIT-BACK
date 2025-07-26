import 'package:capbox/features/coach/presentation/pages/coach_student_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';
import 'package:capbox/features/coach/presentation/widgets/student_list_widget.dart';

class CoachManageStudentsPage extends StatelessWidget {
  final List<String> students = [
    'Arturo Amizaday Jimenez Ojendis',
    'Ana Karen Álvarez Borralles',
    'Jonathan Dzul Mendoza',
    'Nuricumbo Jimenez Pedregal',
    'Alberto Taboada De La Cruz',
  ];

  CoachManageStudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const CoachNavBar(currentIndex: 1),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CoachHeader(),
                  const SizedBox(height: 20),
                  const Text(
                    'Gestion de alumnos',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar alumno',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey.shade900,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ordenar por: Orden alfabetico',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  StudentListWidget(
                    students: students,
                    onStudentTap: (student) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CoachStudentProfilePage(studentName: student),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}