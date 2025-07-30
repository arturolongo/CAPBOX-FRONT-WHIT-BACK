import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cubit/user_stats_cubit.dart';
import '../../../admin/data/services/attendance_service.dart';
import '../../../auth/presentation/view_models/aws_login_cubit.dart';
import '../../../../core/services/aws_api_service.dart';

class BoxerStreakGoals extends StatefulWidget {
  const BoxerStreakGoals({super.key});

  @override
  State<BoxerStreakGoals> createState() => _BoxerStreakGoalsState();
}

class _BoxerStreakGoalsState extends State<BoxerStreakGoals> {
  StreakInfo? _streakInfo;
  bool _isLoadingStreak = true;
  String? _streakError;

  @override
  void initState() {
    super.initState();
    // Cargar datos al inicializar el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserStatsCubit>().loadUserStats();
      _loadUserStreak();
    });
  }

  Future<void> _loadUserStreak() async {
    try {
      final loginCubit = context.read<AWSLoginCubit>();
      final userId = loginCubit.currentUser?.id;

      if (userId == null) {
        setState(() {
          _streakError = 'Usuario no encontrado';
          _isLoadingStreak = false;
        });
        return;
      }

      final apiService = context.read<AWSApiService>();
      final attendanceService = AttendanceService(apiService);

      final streakInfo = await attendanceService.getUserStreak(userId);

      setState(() {
        _streakInfo = streakInfo;
        _isLoadingStreak = false;
      });

      print('🔥 BOXER: Racha cargada - ${streakInfo.rachaActual} días');
    } catch (e) {
      print('❌ BOXER: Error cargando racha - $e');
      setState(() {
        _streakError = 'Error cargando racha';
        _isLoadingStreak = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserStatsCubit>(
      builder: (context, statsCubit, child) {
        return Row(
          children: [
            _buildStreakSection(statsCubit),
            const SizedBox(width: 12),
            _buildGoalsSection(statsCubit),
          ],
        );
      },
    );
  }

  Widget _buildStreakSection(UserStatsCubit statsCubit) {
    // Usar información de racha del backend si está disponible
    String streakText;
    bool isActive;

    if (_isLoadingStreak) {
      streakText = 'Cargando...';
      isActive = false;
    } else if (_streakError != null) {
      streakText = 'Error';
      isActive = false;
    } else if (_streakInfo != null) {
      streakText = _streakInfo!.streakText;
      isActive = _streakInfo!.isActive;
    } else {
      // Fallback al cubit local
      final streak = statsCubit.currentStreak;
      streakText = streak?.streakText ?? 'Sin racha';
      isActive = streak?.isActive ?? false;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset('assets/icons/fire.png', height: 120),
        Column(
          children: [
            if (_isLoadingStreak)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.red,
                  strokeWidth: 2,
                ),
              )
            else
              ImageIcon(
                const AssetImage('assets/icons/fire_card.png'),
                size: 24,
                color: isActive ? Colors.red : Colors.grey,
              ),
            const SizedBox(height: 4),
            Text(
              streakText,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalsSection(UserStatsCubit statsCubit) {
    final goals =
        statsCubit.pendingGoals.take(4).toList(); // Mostrar máximo 4 metas
    final isLoading = statsCubit.isLoading;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '🏁 Metas',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (isLoading)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            if (goals.isEmpty && !isLoading) ...[
              const Text(
                '- No hay metas asignadas',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ] else ...[
              ...goals
                  .map(
                    (goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        children: [
                          Text(
                            goal.categoryIcon,
                            style: const TextStyle(fontSize: 10),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '- ${goal.description}',
                              style: TextStyle(
                                color:
                                    goal.isDueSoon
                                        ? Colors.orangeAccent
                                        : Colors.white70,
                                fontSize: 12,
                                fontFamily: 'Inter',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (goal.isDueSoon)
                            const Icon(
                              Icons.warning,
                              size: 12,
                              color: Colors.orange,
                            ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              if (statsCubit.goals.length > 4)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+ ${statsCubit.goals.length - 4} metas más',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
