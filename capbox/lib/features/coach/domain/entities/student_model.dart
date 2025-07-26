import 'attendance_option_enum.dart';

class Student {
  final String name;
  AttendanceOption status;

  Student({required this.name, this.status = AttendanceOption.none});
}
