import 'package:capbox/core/services/aws_api_service.dart';

class PerformanceService {
  final AWSApiService _apiService;
  PerformanceService(this._apiService);

  /// Registrar sesión de entrenamiento con estructura específica para backend
  Future<TrainingSessionResponseDto> registerTrainingSession({
    required String assignmentId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required int duracionTotalSegundos,
    required int tiempoObjetivoSegundos,
    required int ejerciciosCompletados,
    required List<SeccionEntrenamientoDto> secciones,
  }) async {
    try {
      final payload = {
        'assignmentId': assignmentId,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin.toIso8601String(),
        'duracionTotalSegundos': duracionTotalSegundos,
        'tiempoObjetivoSegundos': tiempoObjetivoSegundos,
        'ejerciciosCompletados': ejerciciosCompletados,
        'secciones': secciones.map((s) => s.toJson()).toList(),
      };

      print('🟢 [PerformanceService] POST /performance/v1/sessions/training');
      print(
        '📋 [PerformanceService] Registrando sesión con ${secciones.length} secciones',
      );
      print('📊 [PerformanceService] Payload:');
      print(payload);

      final response = await _apiService.post(
        '/performance/v1/sessions/training',
        data: payload,
      );

      print('✅ [PerformanceService] Response status: ${response.statusCode}');
      print('📊 [PerformanceService] Response data:');
      print(response.data);

      final resultado = TrainingSessionResponseDto.fromJson(response.data);
      print('✅ [PerformanceService] Sesión registrada con ID: ${resultado.id}');
      print(
        '🏆 [PerformanceService] Racha actualizada: ${resultado.rachaActualizada}',
      );

      return resultado;
    } catch (e) {
      print('❌ [PerformanceService] ERROR registrando sesión: $e');
      if (e.toString().contains('401')) {
        print(
          '📝 [PerformanceService] Token de autenticación inválido o expirado',
        );
      } else if (e.toString().contains('403')) {
        print(
          '📝 [PerformanceService] Sin permisos para registrar sesiones (solo atletas)',
        );
      } else if (e.toString().contains('404')) {
        print('📝 [PerformanceService] Assignment no encontrado');
      } else if (e.toString().contains('422')) {
        print('📝 [PerformanceService] Datos de sesión inválidos');
      }
      rethrow;
    }
  }

  /// Obtener historial de sesiones del atleta
  Future<List<TrainingSessionHistoryDto>> getMyTrainingSessions() async {
    try {
      print('🟢 [PerformanceService] GET /performance/v1/sessions/me');

      final response = await _apiService.get('/performance/v1/sessions/me');

      print('✅ [PerformanceService] Response status: ${response.statusCode}');
      print('📊 [PerformanceService] Response data:');
      print(response.data);

      if (response.data is List) {
        final sesiones =
            (response.data as List)
                .map((e) => TrainingSessionHistoryDto.fromJson(e))
                .toList();
        print('✅ [PerformanceService] ${sesiones.length} sesiones cargadas');
        return sesiones;
      } else {
        print(
          '❌ [PerformanceService] RESPUESTA INESPERADA: expected List, got ${response.data.runtimeType}',
        );
        return [];
      }
    } catch (e) {
      print('❌ [PerformanceService] ERROR obteniendo historial: $e');
      rethrow;
    }
  }
}

/// DTO para sección de entrenamiento
class SeccionEntrenamientoDto {
  final String categoria; // 'calentamiento', 'resistencia', 'tecnica'
  final int tiempoUsadoSegundos;
  final int tiempoObjetivoSegundos;
  final int ejerciciosCompletados;

  SeccionEntrenamientoDto({
    required this.categoria,
    required this.tiempoUsadoSegundos,
    required this.tiempoObjetivoSegundos,
    required this.ejerciciosCompletados,
  });

  Map<String, dynamic> toJson() => {
    'categoria': categoria,
    'tiempoUsadoSegundos': tiempoUsadoSegundos,
    'tiempoObjetivoSegundos': tiempoObjetivoSegundos,
    'ejerciciosCompletados': ejerciciosCompletados,
  };
}

/// DTO para respuesta de registro de sesión
class TrainingSessionResponseDto {
  final int statusCode;
  final String id;
  final String message;
  final int rachaActualizada;

  TrainingSessionResponseDto({
    required this.statusCode,
    required this.id,
    required this.message,
    required this.rachaActualizada,
  });

  factory TrainingSessionResponseDto.fromJson(Map<String, dynamic> json) {
    return TrainingSessionResponseDto(
      statusCode: json['statusCode'] ?? 201,
      id: json['id'],
      message: json['message'],
      rachaActualizada: json['rachaActualizada'] ?? 0,
    );
  }
}

/// DTO para historial de sesiones
class TrainingSessionHistoryDto {
  final String id;
  final String atletaId;
  final String? routineAssignmentId;
  final DateTime startTime;
  final DateTime endTime;
  final int rpeScore;
  final List<dynamic> metricas;

  TrainingSessionHistoryDto({
    required this.id,
    required this.atletaId,
    this.routineAssignmentId,
    required this.startTime,
    required this.endTime,
    required this.rpeScore,
    required this.metricas,
  });

  factory TrainingSessionHistoryDto.fromJson(Map<String, dynamic> json) {
    return TrainingSessionHistoryDto(
      id: json['id'],
      atletaId: json['atletaId'],
      routineAssignmentId: json['routineAssignmentId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      rpeScore: json['rpeScore'] ?? 0,
      metricas: json['metricas'] ?? [],
    );
  }
}
