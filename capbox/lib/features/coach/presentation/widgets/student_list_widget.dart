import 'package:flutter/material.dart';

class StudentListWidget extends StatelessWidget {
  final List<String> students;
  final void Function(String)? onStudentTap;

  const StudentListWidget({
    super.key,
    required this.students,
    this.onStudentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.pink,
                  child: Text('J', style: TextStyle(color: Colors.white)),
                ),
                title: Text(
                  student,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  if (onStudentTap != null) {
                    onStudentTap!(student);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}