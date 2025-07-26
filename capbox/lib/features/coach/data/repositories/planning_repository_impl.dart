import '../../domain/entities/routine.dart';
import '../../domain/repositories/planning_repository.dart';
import '../../../boxer/domain/entities/training_session.dart';
import '../data_sources/planning_api_client.dart';
import '../mappers/routine_mapper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PlanningRepositoryImpl implements PlanningRepository {
  final PlanningApiClient _apiClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  PlanningRepositoryImpl(this._apiClient);

  Future<String> _getToken() async {
    final token = await _secureStorage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('No authentication token found');
    }
    return token;
  }

  @override
  Future<List<Routine>> getRoutines({String? nivel}) async {
    final token = await _getToken();
    final routineDtos = await _apiClient.getRoutines(
      nivel: nivel,
      token: token,
    );
    return routineDtos.map((dto) => RoutineMapper.fromListDto(dto)).toList();
  }

  @override
  Future<Routine> getRoutineDetail(String routineId) async {
    final token = await _getToken();
    final routineDto = await _apiClient.getRoutineDetail(routineId, token);
    return RoutineMapper.fromDetailDto(routineDto);
  }

  @override
  Future<List<AthleteAssignment>> getMyAssignments() async {
    final token = await _getToken();
    final assignmentDtos = await _apiClient.getMyAssignments(token);
    return assignmentDtos.map((dto) => AssignmentMapper.fromDto(dto)).toList();
  }

  @override
  Future<void> assignRoutine({
    required String athleteId,
    required String routineId,
  }) async {
    final token = await _getToken();
    await _apiClient.assignRoutine(
      athleteId: athleteId,
      routineId: routineId,
      token: token,
    );
  }

  @override
  Future<void> updateAssignmentStatus({
    required String assignmentId,
    required String status,
  }) async {
    final token = await _getToken();
    await _apiClient.updateAssignmentStatus(
      assignmentId: assignmentId,
      status: status,
      token: token,
    );
  }

  @override
  Future<void> createRoutine({
    required String nombre,
    required String nivel,
    required List<Exercise> ejercicios,
  }) async {
    final token = await _getToken();

    // Convertir ejercicios a formato esperado por el API
    final ejerciciosData =
        ejercicios
            .map(
              (exercise) => {
                'nombre': exercise.name,
                'setsReps': exercise.description,
              },
            )
            .toList();

    await _apiClient.createRoutine(
      nombre: nombre,
      nivel: nivel,
      ejercicios: ejerciciosData,
      token: token,
    );
  }

  @override
  Future<List<Routine>> getCoachRoutines(String coachId) async {
    final token = await _getToken();
    final routineDtos = await _apiClient.getCoachRoutines(coachId, token);
    return routineDtos.map((dto) => RoutineMapper.fromListDto(dto)).toList();
  }
}
