import 'package:dio/dio.dart';
import '../../../../core/api/api_config.dart';
import '../dtos/routine_dto.dart';

class PlanningApiClient {
  final Dio _dio;

  PlanningApiClient(this._dio);

  /// Obtener lista de rutinas (con filtro opcional por nivel)
  Future<List<RoutineListDto>> getRoutines({
    String? nivel,
    required String token,
  }) async {
    String endpoint = ApiConfig.routines;
    if (nivel != null) {
      endpoint = ApiConfig.routinesFiltered(nivel);
    }

    final response = await _dio.get(
      ApiConfig.getPlanificacionUrl(endpoint),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return (response.data as List)
        .map((json) => RoutineListDto.fromJson(json))
        .toList();
  }

  /// Obtener detalle de una rutina específica
  Future<RoutineDetailDto> getRoutineDetail(
    String routineId,
    String token,
  ) async {
    final response = await _dio.get(
      ApiConfig.getPlanificacionUrl(ApiConfig.routineById(routineId)),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return RoutineDetailDto.fromJson(response.data);
  }

  /// Obtener asignaciones del usuario autenticado
  Future<List<AssignmentDto>> getMyAssignments(String token) async {
    final response = await _dio.get(
      ApiConfig.getPlanificacionUrl(ApiConfig.myAssignments),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return (response.data as List)
        .map((json) => AssignmentDto.fromJson(json))
        .toList();
  }

  /// Asignar rutina a un atleta (para entrenadores)
  Future<Map<String, dynamic>> assignRoutine({
    required String athleteId,
    required String routineId,
    required String token,
  }) async {
    final response = await _dio.post(
      ApiConfig.getPlanificacionUrl('/v1/planning/assignments'),
      data: {
        'athleteId': athleteId,
        'routineId': routineId,
        'tipoPlan': 'Rutina',
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  /// Actualizar estado de una asignación
  Future<Map<String, dynamic>> updateAssignmentStatus({
    required String assignmentId,
    required String status,
    required String token,
  }) async {
    final response = await _dio.patch(
      ApiConfig.getPlanificacionUrl('/v1/planning/assignments/$assignmentId'),
      data: {'estado': status},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  /// Crear nueva rutina (para entrenadores)
  Future<Map<String, dynamic>> createRoutine({
    required String nombre,
    required String nivel,
    required List<Map<String, dynamic>> ejercicios,
    required String token,
  }) async {
    final response = await _dio.post(
      ApiConfig.getPlanificacionUrl('/v1/planning/routines'),
      data: {'nombre': nombre, 'nivel': nivel, 'ejercicios': ejercicios},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  /// Obtener rutinas creadas por un entrenador específico
  Future<List<RoutineListDto>> getCoachRoutines(
    String coachId,
    String token,
  ) async {
    final response = await _dio.get(
      ApiConfig.getPlanificacionUrl('/v1/planning/routines/coach/$coachId'),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return (response.data as List)
        .map((json) => RoutineListDto.fromJson(json))
        .toList();
  }
}
