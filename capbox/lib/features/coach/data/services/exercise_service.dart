import 'package:capbox/core/services/aws_api_service.dart';

class ExerciseService {
  final AWSApiService _apiService;
  ExerciseService(this._apiService);

  /// Obtener ejercicios disponibles para boxeo (sportId = 1)
  Future<List<ExerciseDto>> getExercises() async {
    try {
      print('🟢 [ExerciseService] GET /planning/v1/exercises?sportId=1');
      print(
        '📋 [ExerciseService] Obteniendo ejercicios disponibles para Boxeo',
      );

      final response = await _apiService.get(
        '/planning/v1/exercises?sportId=1',
      );

      print('✅ [ExerciseService] Response status: ${response.statusCode}');
      print('📊 [ExerciseService] Response data:');
      print(response.data);

      if (response.data is List) {
        final ejercicios =
            (response.data as List)
                .map((e) => ExerciseDto.fromJson(e))
                .toList();
        print('✅ [ExerciseService] ${ejercicios.length} ejercicios cargados');
        return ejercicios;
      } else {
        print(
          '❌ [ExerciseService] RESPUESTA INESPERADA: expected List, got ${response.data.runtimeType}',
        );
        print('❌ [ExerciseService] Contenido: ${response.data}');
        return [];
      }
    } catch (e) {
      print('❌ [ExerciseService] ERROR obteniendo ejercicios: $e');
      if (e.toString().contains('404')) {
        print(
          '📝 [ExerciseService] Endpoint /planning/v1/exercises no encontrado en backend',
        );
      } else if (e.toString().contains('401')) {
        print(
          '📝 [ExerciseService] Token de autenticación inválido o expirado',
        );
      } else if (e.toString().contains('403')) {
        print('📝 [ExerciseService] Sin permisos para consultar ejercicios');
      }
      rethrow;
    }
  }

  /// Obtener detalle de un ejercicio específico (si se necesita en el futuro)
  Future<ExerciseDto?> getExerciseDetail(String id) async {
    try {
      print('🟢 [ExerciseService] GET /planning/v1/exercises/$id');
      print('📋 [ExerciseService] Obteniendo detalle del ejercicio ID: $id');

      final response = await _apiService.get('/planning/v1/exercises/$id');

      print('✅ [ExerciseService] Response status: ${response.statusCode}');
      print('📊 [ExerciseService] Response data:');
      print(response.data);

      final ejercicio = ExerciseDto.fromJson(response.data);
      print('✅ [ExerciseService] Ejercicio cargado: ${ejercicio.nombre}');

      return ejercicio;
    } catch (e) {
      print('❌ [ExerciseService] ERROR obteniendo detalle de ejercicio: $e');
      if (e.toString().contains('404')) {
        print('📝 [ExerciseService] Ejercicio con ID $id no encontrado');
      }
      return null;
    }
  }
}

/// DTO para ejercicio
class ExerciseDto {
  final String id;
  final String nombre;
  final String? descripcion;

  ExerciseDto({required this.id, required this.nombre, this.descripcion});

  factory ExerciseDto.fromJson(Map<String, dynamic> json) {
    return ExerciseDto(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
  };
}
