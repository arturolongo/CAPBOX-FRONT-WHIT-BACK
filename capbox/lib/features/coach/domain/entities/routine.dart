class Routine {
  final String id;
  final String sportId; // FK to sports
  final String coachId; // FK to users
  final String name;
  final String targetLevel;
  final String description;
  final DateTime dueDate;

  Routine({
    required this.id,
    required this.sportId,
    required this.coachId,
    required this.name,
    required this.targetLevel,
    required this.description,
    required this.dueDate,
  });

  Routine copyWith({
    String? id,
    String? sportId,
    String? coachId,
    String? name,
    String? targetLevel,
    String? description,
    DateTime? dueDate,
  }) {
    return Routine(
      id: id ?? this.id,
      sportId: sportId ?? this.sportId,
      coachId: coachId ?? this.coachId,
      name: name ?? this.name,
      targetLevel: targetLevel ?? this.targetLevel,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}

class Exercise {
  final String id;
  final String sportId; // FK to sports
  final String name;
  final String description;

  Exercise({
    required this.id,
    required this.sportId,
    required this.name,
    required this.description,
  });

  Exercise copyWith({
    String? id,
    String? sportId,
    String? name,
    String? description,
  }) {
    return Exercise(
      id: id ?? this.id,
      sportId: sportId ?? this.sportId,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}

class RoutineExercise {
  final String routineId;
  final String exerciseId;
  final int order;
  final String setsReps; // e.g., "3x15", "5x3"

  RoutineExercise({
    required this.routineId,
    required this.exerciseId,
    required this.order,
    required this.setsReps,
  });

  RoutineExercise copyWith({
    String? routineId,
    String? exerciseId,
    int? order,
    String? setsReps,
  }) {
    return RoutineExercise(
      routineId: routineId ?? this.routineId,
      exerciseId: exerciseId ?? this.exerciseId,
      order: order ?? this.order,
      setsReps: setsReps ?? this.setsReps,
    );
  }
}
