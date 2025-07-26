enum CombatEventType { sparring, competition, exhibition }

enum CombatResult { win, loss, draw, noContest }

class CombatEvent {
  final String id;
  final String athleteId;
  final CombatEventType eventType;
  final DateTime eventDate;
  final String opponentName;
  final CombatResult result;

  CombatEvent({
    required this.id,
    required this.athleteId,
    required this.eventType,
    required this.eventDate,
    required this.opponentName,
    required this.result,
  });

  CombatEvent copyWith({
    String? id,
    String? athleteId,
    CombatEventType? eventType,
    DateTime? eventDate,
    String? opponentName,
    CombatResult? result,
  }) {
    return CombatEvent(
      id: id ?? this.id,
      athleteId: athleteId ?? this.athleteId,
      eventType: eventType ?? this.eventType,
      eventDate: eventDate ?? this.eventDate,
      opponentName: opponentName ?? this.opponentName,
      result: result ?? this.result,
    );
  }
}

class CoachObservation {
  final String id;
  final String coachId;
  final String athleteId;
  final String? sessionId; // FK to training_sessions
  final String? combatEventId; // FK to combat_events
  final String observationText;
  final DateTime createdAt;

  CoachObservation({
    required this.id,
    required this.coachId,
    required this.athleteId,
    this.sessionId,
    this.combatEventId,
    required this.observationText,
    required this.createdAt,
  });

  CoachObservation copyWith({
    String? id,
    String? coachId,
    String? athleteId,
    String? sessionId,
    String? combatEventId,
    String? observationText,
    DateTime? createdAt,
  }) {
    return CoachObservation(
      id: id ?? this.id,
      coachId: coachId ?? this.coachId,
      athleteId: athleteId ?? this.athleteId,
      sessionId: sessionId ?? this.sessionId,
      combatEventId: combatEventId ?? this.combatEventId,
      observationText: observationText ?? this.observationText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isSessionObservation => sessionId != null;
  bool get isCombatObservation => combatEventId != null;
}
