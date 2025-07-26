/// DTO para estadísticas completas del usuario
class UserStatsDto {
  final StreakDto streak;
  final List<GoalDto> goals;
  final int totalWorkouts;
  final double totalHours;
  final String favoriteExercise;
  final int weeklyGoal;
  final int weeklyCompleted;

  UserStatsDto({
    required this.streak,
    required this.goals,
    required this.totalWorkouts,
    required this.totalHours,
    required this.favoriteExercise,
    required this.weeklyGoal,
    required this.weeklyCompleted,
  });

  factory UserStatsDto.fromJson(Map<String, dynamic> json) {
    return UserStatsDto(
      streak:
          json['racha'] != null
              ? StreakDto.fromJson(json['racha'])
              : StreakDto.empty(),
      goals:
          json['metas'] != null
              ? (json['metas'] as List).map((g) => GoalDto.fromJson(g)).toList()
              : [],
      totalWorkouts: json['totalEntrenamientos'] ?? json['totalWorkouts'] ?? 0,
      totalHours: (json['totalHoras'] ?? json['totalHours'] ?? 0.0).toDouble(),
      favoriteExercise:
          json['ejercicioFavorito'] ?? json['favoriteExercise'] ?? '',
      weeklyGoal: json['metaSemanal'] ?? json['weeklyGoal'] ?? 5,
      weeklyCompleted:
          json['semanalesCompletos'] ?? json['weeklyCompleted'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'racha': streak.toJson(),
      'metas': goals.map((g) => g.toJson()).toList(),
      'totalEntrenamientos': totalWorkouts,
      'totalHoras': totalHours,
      'ejercicioFavorito': favoriteExercise,
      'metaSemanal': weeklyGoal,
      'semanalesCompletos': weeklyCompleted,
    };
  }

  /// Crear estadísticas vacías
  factory UserStatsDto.empty() {
    return UserStatsDto(
      streak: StreakDto.empty(),
      goals: [],
      totalWorkouts: 0,
      totalHours: 0.0,
      favoriteExercise: '',
      weeklyGoal: 5,
      weeklyCompleted: 0,
    );
  }
}

/// DTO para racha de entrenamientos
class StreakDto {
  final int currentDays;
  final int maxDays;
  final DateTime? lastWorkoutDate;
  final int currentMonth;
  final List<DateTime> workoutDatesThisMonth;

  StreakDto({
    required this.currentDays,
    required this.maxDays,
    this.lastWorkoutDate,
    required this.currentMonth,
    required this.workoutDatesThisMonth,
  });

  factory StreakDto.fromJson(Map<String, dynamic> json) {
    return StreakDto(
      currentDays: json['diasActuales'] ?? json['currentDays'] ?? 0,
      maxDays: json['diasMaximos'] ?? json['maxDays'] ?? 0,
      lastWorkoutDate:
          json['ultimoEntrenamiento'] != null
              ? DateTime.tryParse(json['ultimoEntrenamiento'])
              : null,
      currentMonth:
          json['mesActual'] ?? json['currentMonth'] ?? DateTime.now().month,
      workoutDatesThisMonth:
          json['entrenamientosEsteMes'] != null
              ? (json['entrenamientosEsteMes'] as List)
                  .map((d) => DateTime.parse(d))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diasActuales': currentDays,
      'diasMaximos': maxDays,
      'ultimoEntrenamiento': lastWorkoutDate?.toIso8601String(),
      'mesActual': currentMonth,
      'entrenamientosEsteMes':
          workoutDatesThisMonth.map((d) => d.toIso8601String()).toList(),
    };
  }

  /// Crear racha vacía
  factory StreakDto.empty() {
    return StreakDto(
      currentDays: 0,
      maxDays: 0,
      lastWorkoutDate: null,
      currentMonth: DateTime.now().month,
      workoutDatesThisMonth: [],
    );
  }

  /// Texto descriptivo de la racha
  String get streakText {
    if (currentDays == 0) return 'Sin racha activa';
    if (currentDays == 1) return '1 día de racha';
    return '$currentDays días de racha';
  }

  /// Verificar si la racha está activa
  bool get isActive {
    if (lastWorkoutDate == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastWorkoutDate!).inDays;
    return difference <= 1; // Racha activa si entreó ayer o hoy
  }
}

/// DTO para metas del usuario
class GoalDto {
  final String id;
  final String description;
  final bool isCompleted;
  final DateTime dueDate;
  final String
  category; // 'cardio', 'strength', 'technique', 'weight', 'health'
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final double? progress; // 0.0 a 1.0 para metas con progreso

  GoalDto({
    required this.id,
    required this.description,
    required this.isCompleted,
    required this.dueDate,
    required this.category,
    required this.priority,
    this.progress,
  });

  factory GoalDto.fromJson(Map<String, dynamic> json) {
    return GoalDto(
      id: json['id']?.toString() ?? '',
      description: json['descripcion'] ?? json['description'] ?? '',
      isCompleted: json['completada'] ?? json['isCompleted'] ?? false,
      dueDate:
          json['fechaLimite'] != null
              ? DateTime.parse(json['fechaLimite'])
              : DateTime.now().add(const Duration(days: 30)),
      category: json['categoria'] ?? json['category'] ?? 'general',
      priority: json['prioridad'] ?? json['priority'] ?? 'medium',
      progress: json['progreso']?.toDouble() ?? json['progress']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': description,
      'completada': isCompleted,
      'fechaLimite': dueDate.toIso8601String(),
      'categoria': category,
      'prioridad': priority,
      'progreso': progress,
    };
  }

  /// Verificar si la meta está vencida
  bool get isOverdue {
    return !isCompleted && DateTime.now().isAfter(dueDate);
  }

  /// Verificar si la meta está próxima a vencer (en los próximos 7 días)
  bool get isDueSoon {
    if (isCompleted) return false;
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    return daysUntilDue <= 7 && daysUntilDue >= 0;
  }

  /// Obtener icono según la categoría
  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'cardio':
        return '🏃';
      case 'strength':
        return '💪';
      case 'technique':
        return '🥊';
      case 'weight':
        return '⚖️';
      case 'health':
        return '🩺';
      default:
        return '🎯';
    }
  }

  /// Obtener color según la prioridad
  String get priorityColor {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return 'red';
      case 'high':
        return 'orange';
      case 'medium':
        return 'yellow';
      case 'low':
        return 'green';
      default:
        return 'gray';
    }
  }

  /// Texto descriptivo del progreso
  String get progressText {
    if (isCompleted) return 'Completada ✅';
    if (progress != null) {
      final percentage = (progress! * 100).round();
      return '$percentage% completada';
    }
    if (isOverdue) return 'Vencida ⚠️';
    if (isDueSoon) return 'Próxima a vencer';
    return 'En progreso';
  }
}
