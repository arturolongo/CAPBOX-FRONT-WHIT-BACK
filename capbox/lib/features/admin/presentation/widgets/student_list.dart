import 'package:capbox/features/coach/domain/entities/attendance_option_enum.dart';
import 'package:capbox/features/coach/domain/entities/student_model.dart';
import 'package:flutter/material.dart';
import 'student_tile.dart';

class StudentList extends StatelessWidget {
  final List<Student> studentNames;
  final void Function(int index, AttendanceOption status)? onStatusChanged;

  const StudentList({
    super.key,
    required this.studentNames,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: studentNames.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return StudentTile(
          student: studentNames[index],
          onTap: () async {
            final option = await showModalBottomSheet<AttendanceOption>(
              context: context,
              backgroundColor: Colors.black,
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: const Text('Asistencia', style: TextStyle(color: Colors.white)),
                      onTap: () => Navigator.pop(context, AttendanceOption.present),
                    ),
                    ListTile(
                      leading: const Icon(Icons.cancel, color: Colors.red),
                      title: const Text('Falta', style: TextStyle(color: Colors.white)),
                      onTap: () => Navigator.pop(context, AttendanceOption.absent),
                    ),
                    ListTile(
                      leading: const Icon(Icons.assignment_ind, color: Colors.tealAccent),
                      title: const Text('Permiso', style: TextStyle(color: Colors.white)),
                      onTap: () => Navigator.pop(context, AttendanceOption.permission),
                    ),
                  ],
                );
              },
            );

            if (option != null) {
              onStatusChanged?.call(index, option);
            }
          },
        );
      },
    );
  }
}