import 'package:flutter/material.dart';
import '../../domain/entities/student_model.dart';
import '../../domain/entities/attendance_option_enum.dart';

class StudentTile extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;

  const StudentTile({super.key, required this.student, required this.onTap});

  Icon _buildIconForStatus(AttendanceOption status) {
    switch (status) {
      case AttendanceOption.present:
        return const Icon(Icons.check_circle, color: Colors.green);
      case AttendanceOption.absent:
        return const Icon(Icons.cancel, color: Colors.red);
      case AttendanceOption.permission:
        return const Icon(Icons.assignment_ind, color: Colors.tealAccent);
      default:
        return const Icon(Icons.radio_button_unchecked, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.pink,
          child: Text('J', style: TextStyle(color: Colors.white)),
        ),
        title: Text(
          student.name,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: _buildIconForStatus(student.status),
        onTap: onTap,
      ),
    );
  }
}