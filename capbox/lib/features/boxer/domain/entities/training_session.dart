enum AssignmentStatus { pending, inProgress, completed, cancelled }

class TrainingSession {
  final String id;
  final String athleteId;
  final String routineAssignmentId;
  final DateTime startTime;
  final DateTime endTime;
  final int rpeScore; // Rate of Perceived Exertion (1-10)

  TrainingSession({
    required this.id,
    required this.athleteId,
    required this.routineAssignmentId,
    required this.startTime,
    required this.endTime,
    required this.rpeScore,
  });

  TrainingSession copyWith({
    String? id,
    String? athleteId,
    String? routineAssignmentId,
    DateTime? startTime,
    DateTime? endTime,
    int? rpeScore,
  }) {
    return TrainingSession(
      id: id ?? this.id,
      athleteId: athleteId ?? this.athleteId,
      routineAssignmentId: routineAssignmentId ?? this.routineAssignmentId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      rpeScore: rpeScore ?? this.rpeScore,
    );
  }

  Duration get duration => endTime.difference(startTime);
}

class AthleteAssignment {
  final String id;
  final String athleteId;
  final String assignerId; // Coach ID
  final String? routineId;
  final String? goalId;
  final AssignmentStatus status;
  final DateTime assignedAt;

  AthleteAssignment({
    required this.id,
    required this.athleteId,
    required this.assignerId,
    this.routineId,
    this.goalId,
    required this.status,
    required this.assignedAt,
  });

  AthleteAssignment copyWith({
    String? id,
    String? athleteId,
    String? assignerId,
    String? routineId,
    String? goalId,
    AssignmentStatus? status,
    DateTime? assignedAt,
  }) {
    return AthleteAssignment(
      id: id ?? this.id,
      athleteId: athleteId ?? this.athleteId,
      assignerId: assignerId ?? this.assignerId,
      routineId: routineId ?? this.routineId,
      goalId: goalId ?? this.goalId,
      status: status ?? this.status,
      assignedAt: assignedAt ?? this.assignedAt,
    );
  }
}
