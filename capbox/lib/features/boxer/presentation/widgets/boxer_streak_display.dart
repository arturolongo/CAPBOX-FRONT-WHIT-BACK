import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/aws_api_service.dart';
import '../../../admin/data/services/attendance_service.dart';

class BoxerStreakDisplay extends StatefulWidget {
  const BoxerStreakDisplay({super.key});

  @override
  State<BoxerStreakDisplay> createState() => _BoxerStreakDisplayState();
}

class _BoxerStreakDisplayState extends State<BoxerStreakDisplay> {
  int _currentStreak = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final apiService = context.read<AWSApiService>();
      final userResponse = await apiService.getUserMe();
      final userId = userResponse.data['id'];

      if (userId != null) {
        try {
          final attendanceService = AttendanceService(apiService);
          final streakInfo = await attendanceService.getUserStreak(userId);

          setState(() {
            _currentStreak = streakInfo.rachaActual;
            _isLoading = false;
          });

          print('🔥 BOXER STREAK: Racha actual - $_currentStreak días');
        } catch (streakError) {
          print('❌ BOXER STREAK: Error obteniendo racha - $streakError');
          setState(() {
            _errorMessage = 'Error cargando racha';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Usuario no encontrado';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ BOXER STREAK: Error cargando datos del usuario - $e');
      setState(() {
        _errorMessage = 'Error cargando racha';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.red, Colors.pink],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _loadStreakData,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child:
                      _isLoading
                          ? const Text(
                            'Cargando racha...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                          : _errorMessage != null
                          ? Text(
                            'Error: $_errorMessage',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                          : Text(
                            '$_currentStreak días de racha',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
