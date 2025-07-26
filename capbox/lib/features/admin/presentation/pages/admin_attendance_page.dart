import 'package:capbox/features/coach/domain/entities/attendance_option_enum.dart';
import 'package:capbox/features/coach/domain/entities/student_model.dart';
import 'package:capbox/features/coach/presentation/widgets/student_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_navbar.dart';

class AdminAttendancePage extends StatefulWidget {
  const AdminAttendancePage({super.key});

  @override
  State<AdminAttendancePage> createState() => _AdminAttendancePageState();
}

class _AdminAttendancePageState extends State<AdminAttendancePage> {
  DateTime selectedDate = DateTime.now();
  String searchQuery = '';

  Map<String, List<Student>> attendanceByDate = {};

  List<Student> get currentStudents {
    final dateKey = DateFormat('dd/MM/yyyy').format(selectedDate);
    final list = attendanceByDate[dateKey] ?? _defaultStudents();
    return list
        .where(
          (student) =>
              student.name.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  List<Student> _defaultStudents() {
    return [
      Student(name: "Arturo Amizaday Jimenez Ojendis"),
      Student(name: "Ana Karen Álvarez Borralles"),
      Student(name: "Jonathan Dzul Mendoza"),
      Student(name: "Nuricumbo Jimenez Pedregal"),
      Student(name: "Alberto Taboada De La Cruz"),
    ];
  }

  void _updateStatus(int index, AttendanceOption status) {
    final dateKey = DateFormat('dd/MM/yyyy').format(selectedDate);
    final students = List<Student>.from(
      attendanceByDate[dateKey] ?? _defaultStudents(),
    );

    final updated = students[index];
    updated.status = status;

    setState(() {
      students[index] = updated;
      attendanceByDate[dateKey] = students;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('dd/MM/yyyy').format(selectedDate);

    return Scaffold(
      bottomNavigationBar: const AdminNavBar(currentIndex: 1),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/fondo.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AdminHeader(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Asistencia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Row(
                          children: [
                            Text(
                              dateFormatted,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: const InputDecoration(
                      hintText: 'Buscar alumno',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black54,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StudentList(
                      studentNames: currentStudents,
                      onStatusChanged: _updateStatus,
                    ),
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
