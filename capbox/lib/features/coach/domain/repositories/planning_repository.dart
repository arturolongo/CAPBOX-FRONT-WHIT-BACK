import '../entities/routine.dart';
import '../../../boxer/domain/entities/training_session.dart';

abstract class PlanningRepository {
  Future<List<Routine>> getRoutines({String? nivel});
  Future<Routine> getRoutineDetail(String routineId);
  Future<List<AthleteAssignment>> getMyAssignments();
  Future<void> assignRoutine({
    required String athleteId,
    required String routineId,
  });
  Future<void> updateAssignmentStatus({
    required String assignmentId,
    required String status,
  });
  Future<void> createRoutine({
    required String nombre,
    required String nivel,
    required List<Exercise> ejercicios,
  });
  Future<List<Routine>> getCoachRoutines(String coachId);
}
