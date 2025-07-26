import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/student_model.dart';
import '../../domain/entities/attendance_option_enum.dart';
import '../widgets/coach_header.dart';
import '../widgets/coach_navbar.dart';
import '../widgets/student_list.dart';

class CoachAttendancePage extends StatefulWidget {
  const CoachAttendancePage({super.key});

  @override
  State<CoachAttendancePage> createState() => _CoachAttendancePageState();
}

class _CoachAttendancePageState extends State<CoachAttendancePage> {
  final _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  List<Student> students = [
    Student(name: 'Arturo Amizaday Jimenez Ojendis', status: AttendanceOption.permission),
    Student(name: 'Arturo Amizaday Jimenez Ojendis', status: AttendanceOption.present),
    Student(name: 'Arturo Amizaday Jimenez Ojendis', status: AttendanceOption.permission),
    Student(name: 'Arturo Amizaday Jimenez Ojendis', status: AttendanceOption.present),
  ];

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(data: ThemeData.dark(), child: child!);
      },
    );
    if (date != null) setState(() => _selectedDate = date);
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const CoachHeader(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Asistencia',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      InkWell(
                        onTap: _pickDate,
                        child: Row(
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(_selectedDate),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.calendar_today, size: 18, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      hintText: 'Buscar alumno',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StudentList(
                      studentNames: students,
                      onStatusChanged: (index, status) {
                        setState(() => students[index].status = status);
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/coach-home');
                    },
                    child: const Text('Guardar lista'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 1, 161, 81),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
