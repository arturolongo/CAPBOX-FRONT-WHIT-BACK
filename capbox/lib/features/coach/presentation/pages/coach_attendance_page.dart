import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/coach_header.dart';
import '../widgets/coach_navbar.dart';
import '../../../admin/data/services/attendance_service.dart';
import '../../../auth/presentation/view_models/aws_login_cubit.dart';
import '../../../../core/services/aws_api_service.dart';

class CoachAttendancePage extends StatefulWidget {
  const CoachAttendancePage({super.key});

  @override
  State<CoachAttendancePage> createState() => _CoachAttendancePageState();
}

class _CoachAttendancePageState extends State<CoachAttendancePage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  AttendanceResponse? _attendanceData;
  bool _isLoading = false;
  String? _errorMessage;
  String? _gymId;
  AttendanceService? _attendanceService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    try {
      // Obtener información del gimnasio del usuario actual
      final apiService = context.read<AWSApiService>();
      _attendanceService = AttendanceService(apiService);

      final response = await apiService.getUserMe();
      final userData = response.data;
      final gimnasio = userData['gimnasio'];

      if (gimnasio != null) {
        _gymId = gimnasio['id'];
        await _loadAttendanceForDate(_selectedDate);
      } else {
        setState(() {
          _errorMessage = 'No estás vinculado a ningún gimnasio';
        });
      }
    } catch (e) {
      print('❌ COACH ATTENDANCE: Error inicializando - $e');
      setState(() {
        _errorMessage = 'Error cargando información del gimnasio';
      });
    }
  }

  Future<void> _loadAttendanceForDate(DateTime date) async {
    if (_gymId == null || _attendanceService == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print(
        '📅 COACH ATTENDANCE: Cargando asistencia para ${date.toIso8601String().split('T')[0]}',
      );

      final attendanceData = await _attendanceService!.getAttendanceByDate(
        gymId: _gymId!,
        fecha: date,
      );

      setState(() {
        _attendanceData = attendanceData;
        _isLoading = false;
      });

      print(
        '✅ COACH ATTENDANCE: ${attendanceData.alumnos.length} alumnos cargados',
      );
    } catch (e) {
      print('❌ COACH ATTENDANCE: Error cargando asistencia - $e');
      setState(() {
        _errorMessage = 'Error cargando asistencia: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateAttendance(
    String studentId,
    AttendanceStatus status,
  ) async {
    if (_gymId == null || _attendanceService == null) return;

    try {
      print('📝 COACH ATTENDANCE: Actualizando asistencia individual');

      await _attendanceService!.updateIndividualAttendance(
        gymId: _gymId!,
        fecha: _selectedDate,
        alumnoId: studentId,
        status: status,
      );

      // Recargar datos para ver los cambios
      await _loadAttendanceForDate(_selectedDate);

      // Actualizar la racha del estudiante específico
      await _updateStudentStreak(studentId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Asistencia actualizada: ${status.displayName}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('❌ COACH ATTENDANCE: Error actualizando asistencia - $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error actualizando asistencia: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Actualizar la racha de un estudiante específico
  Future<void> _updateStudentStreak(String studentId) async {
    try {
      print(
        '🔥 COACH ATTENDANCE: Actualizando racha del estudiante $studentId',
      );

      final streakInfo = await _attendanceService!.getUserStreak(studentId);
      print(
        '✅ COACH ATTENDANCE: Racha actualizada - ${streakInfo.rachaActual} días',
      );

      // Forzar actualización de la UI
      setState(() {
        // Esto forzará a que se reconstruya la lista con los datos actualizados
      });
    } catch (e) {
      print('❌ COACH ATTENDANCE: Error actualizando racha - $e');
      // No mostrar error al usuario, solo log
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const CoachNavBar(currentIndex: 0),
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset('assets/images/fondo.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),

          // Contenido
          SafeArea(
            child: Column(
              children: [
                // Header
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CoachHeader(),
                ),

                // Título
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Asistencia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Calendario
                _buildCalendar(),

                const SizedBox(height: 16),

                // Lista de asistencia
                Expanded(child: _buildAttendanceList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TableCalendar<dynamic>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDate,
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        calendarFormat: CalendarFormat.week,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: Colors.white70),
          defaultTextStyle: TextStyle(color: Colors.white),
          selectedTextStyle: TextStyle(color: Colors.white),
          todayTextStyle: TextStyle(color: Colors.white),
          selectedDecoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.white70),
          weekendStyle: TextStyle(color: Colors.white70),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
            _focusedDate = focusedDay;
          });
          _loadAttendanceForDate(selectedDay);
        },
        onPageChanged: (focusedDay) {
          _focusedDate = focusedDay;
        },
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (_errorMessage != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _initializeData(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }

    if (_attendanceData == null || _attendanceData!.alumnos.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people_outline, color: Colors.grey, size: 48),
              const SizedBox(height: 16),
              const Text(
                'No hay alumnos registrados para esta fecha',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _selectedDate.toIso8601String().split('T')[0],
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _attendanceData!.alumnos.length,
      itemBuilder: (context, index) {
        final student = _attendanceData!.alumnos[index];
        return _buildStudentCard(student);
      },
    );
  }

  Widget _buildStudentCard(StudentAttendance student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del estudiante
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.red,
                radius: 20,
                child: Text(
                  student.nombre.isNotEmpty
                      ? student.nombre[0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${student.rachaActual} días de racha',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Botones de asistencia
          Row(
            children: [
              Expanded(
                child: _buildAttendanceButton(
                  'Presente',
                  AttendanceStatus.presente,
                  Colors.green,
                  student.status == AttendanceStatus.presente,
                  () =>
                      _updateAttendance(student.id, AttendanceStatus.presente),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAttendanceButton(
                  'Faltó',
                  AttendanceStatus.falto,
                  Colors.red,
                  student.status == AttendanceStatus.falto,
                  () => _updateAttendance(student.id, AttendanceStatus.falto),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAttendanceButton(
                  'Permiso',
                  AttendanceStatus.permiso,
                  Colors.orange,
                  student.status == AttendanceStatus.permiso,
                  () => _updateAttendance(student.id, AttendanceStatus.permiso),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceButton(
    String label,
    AttendanceStatus status,
    Color color,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey.withOpacity(0.3),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
