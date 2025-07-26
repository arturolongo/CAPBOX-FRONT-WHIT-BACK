import 'attendance_option_enum.dart';

class Student {
  final String name;
  final AttendanceOption status;

  Student({
    required this.name,
    this.status = AttendanceOption.none,
  });

  Student copyWith({
    String? name,
    AttendanceOption? status,
  }) {
    return Student(
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }
}