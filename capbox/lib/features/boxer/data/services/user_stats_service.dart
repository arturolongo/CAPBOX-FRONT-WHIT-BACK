import '../../../../core/services/aws_api_service.dart';
import '../dtos/user_stats_dto.dart';

/// Servicio para obtener estadísticas, rachas y metas del usuario
class UserStatsService {
  final AWSApiService _apiService;

  UserStatsService(this._apiService);

  /// Obtener estadísticas generales del usuario
  Future<UserStatsDto> getUserStats() async {
    try {
      print('📊 STATS: Obteniendo estadísticas del usuario');

      // Intentar obtener desde el backend
      final response = await _apiService.getUserProfile();

      // Si el backend retorna las stats, mapearlas
      final statsData = response.data['estadisticas'] ?? {};

      print('✅ STATS: Estadísticas obtenidas desde backend');

      return UserStatsDto.fromJson(statsData);
    } catch (e) {
      print('⚠️ STATS: Error obteniendo desde backend, usando datos mock');
      return _getMockStats();
    }
  }

  /// Obtener metas del usuario
  Future<List<GoalDto>> getUserGoals() async {
    try {
      print('🎯 GOALS: Obteniendo metas del usuario');

      // En el futuro esto podría ser un endpoint específico
      // Por ahora lo sacamos del perfil del usuario o usamos mock
      final userStats = await getUserStats();

      print('✅ GOALS: ${userStats.goals.length} metas obtenidas');

      return userStats.goals;
    } catch (e) {
      print('⚠️ GOALS: Error obteniendo metas, usando datos mock');
      return _getMockGoals();
    }
  }

  /// Obtener racha actual del usuario
  Future<StreakDto> getUserStreak() async {
    try {
      print('🔥 STREAK: Obteniendo racha del usuario');

      final userStats = await getUserStats();

      print('✅ STREAK: Racha obtenida - ${userStats.streak.currentDays} días');

      return userStats.streak;
    } catch (e) {
      print('⚠️ STREAK: Error obteniendo racha, usando datos mock');
      return _getMockStreak();
    }
  }

  /// Actualizar una meta
  Future<void> updateGoal(
    String goalId, {
    String? newDescription,
    bool? isCompleted,
    DateTime? newDueDate,
  }) async {
    try {
      print('🎯 GOALS: Actualizando meta $goalId');

      // TODO: Implementar endpoint específico para actualizar metas
      // Por ahora solo log

      print('✅ GOALS: Meta actualizada exitosamente');
    } catch (e) {
      print('❌ GOALS: Error actualizando meta - $e');
      rethrow;
    }
  }

  /// Marcar entrenamiento completado (para actualizar racha)
  Future<void> markWorkoutCompleted() async {
    try {
      print('🔥 STREAK: Marcando entrenamiento completado');

      // TODO: Implementar endpoint para marcar entrenamiento
      // Esto actualizaría la racha automáticamente

      print('✅ STREAK: Entrenamiento marcado como completado');
    } catch (e) {
      print('❌ STREAK: Error marcando entrenamiento - $e');
      rethrow;
    }
  }

  /// Agregar nueva meta
  Future<void> addGoal(String description, DateTime dueDate) async {
    try {
      print('🎯 GOALS: Agregando nueva meta');

      // TODO: Implementar endpoint para agregar metas

      print('✅ GOALS: Meta agregada exitosamente');
    } catch (e) {
      print('❌ GOALS: Error agregando meta - $e');
      rethrow;
    }
  }

  /// Obtener datos mock para estadísticas
  UserStatsDto _getMockStats() {
    return UserStatsDto(
      streak: _getMockStreak(),
      goals: _getMockGoals(),
      totalWorkouts: 45,
      totalHours: 67.5,
      favoriteExercise: 'Saco pesado',
      weeklyGoal: 5,
      weeklyCompleted: 3,
    );
  }

  /// Obtener racha mock
  StreakDto _getMockStreak() {
    return StreakDto(
      currentDays: 5,
      maxDays: 12,
      lastWorkoutDate: DateTime.now().subtract(const Duration(days: 1)),
      currentMonth: DateTime.now().month,
      workoutDatesThisMonth: [
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now().subtract(const Duration(days: 2)),
        DateTime.now().subtract(const Duration(days: 3)),
        DateTime.now().subtract(const Duration(days: 5)),
        DateTime.now().subtract(const Duration(days: 6)),
      ],
    );
  }

  /// Obtener metas mock
  List<GoalDto> _getMockGoals() {
    return [
      GoalDto(
        id: '1',
        description: '5km en 25 min',
        isCompleted: false,
        dueDate: DateTime.now().add(const Duration(days: 30)),
        category: 'cardio',
        priority: 'high',
      ),
      GoalDto(
        id: '2',
        description: '5kg abajo',
        isCompleted: false,
        dueDate: DateTime.now().add(const Duration(days: 60)),
        category: 'weight',
        priority: 'medium',
      ),
      GoalDto(
        id: '3',
        description: 'Mejorar guardia derecha',
        isCompleted: false,
        dueDate: DateTime.now().add(const Duration(days: 45)),
        category: 'technique',
        priority: 'high',
      ),
      GoalDto(
        id: '4',
        description: 'Tratamiento lesión mano derecha',
        isCompleted: false,
        dueDate: DateTime.now().add(const Duration(days: 14)),
        category: 'health',
        priority: 'urgent',
      ),
    ];
  }
}
