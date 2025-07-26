enum CaptureRequestStatus { pending, inProgress, completed, cancelled }

class StandardizedTest {
  final String id;
  final String sportId;
  final String name;
  final String instructions;
  final String metricUnit; // e.g., "seconds", "kg", "repetitions"

  StandardizedTest({
    required this.id,
    required this.sportId,
    required this.name,
    required this.instructions,
    required this.metricUnit,
  });

  StandardizedTest copyWith({
    String? id,
    String? sportId,
    String? name,
    String? instructions,
    String? metricUnit,
  }) {
    return StandardizedTest(
      id: id ?? this.id,
      sportId: sportId ?? this.sportId,
      name: name ?? this.name,
      instructions: instructions ?? this.instructions,
      metricUnit: metricUnit ?? this.metricUnit,
    );
  }
}

class TestResult {
  final String athleteId;
  final String testId;
  final DateTime testDate;
  final double resultValue;
  final double normalizedScore; // Normalized 0-100 score

  TestResult({
    required this.athleteId,
    required this.testId,
    required this.testDate,
    required this.resultValue,
    required this.normalizedScore,
  });

  TestResult copyWith({
    String? athleteId,
    String? testId,
    DateTime? testDate,
    double? resultValue,
    double? normalizedScore,
  }) {
    return TestResult(
      athleteId: athleteId ?? this.athleteId,
      testId: testId ?? this.testId,
      testDate: testDate ?? this.testDate,
      resultValue: resultValue ?? this.resultValue,
      normalizedScore: normalizedScore ?? this.normalizedScore,
    );
  }
}

class DataCaptureRequest {
  final String id;
  final String athleteId;
  final String coachId;
  final CaptureRequestStatus status;
  final DateTime requestedAt;

  DataCaptureRequest({
    required this.id,
    required this.athleteId,
    required this.coachId,
    required this.status,
    required this.requestedAt,
  });

  DataCaptureRequest copyWith({
    String? id,
    String? athleteId,
    String? coachId,
    CaptureRequestStatus? status,
    DateTime? requestedAt,
  }) {
    return DataCaptureRequest(
      id: id ?? this.id,
      athleteId: athleteId ?? this.athleteId,
      coachId: coachId ?? this.coachId,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
    );
  }
}
