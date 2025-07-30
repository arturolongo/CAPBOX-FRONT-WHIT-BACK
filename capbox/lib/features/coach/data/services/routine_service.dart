import 'package:capbox/core/services/aws_api_service.dart';
import 'package:capbox/features/coach/data/dtos/routine_dto.dart';

class RoutineService {
  final AWSApiService _apiService;
  RoutineService(this._apiService);

  /// Obtener lista de rutinas, opcionalmente filtradas por nivel
  Future<List<RoutineListDto>> getRoutines({String? nivel}) async {
    try {
      String endpoint = '/planning/v1/routines';
      // Eliminar filtro de nivel para mostrar todas las rutinas
      // if (nivel != null) {
      //   endpoint += '?nivel=$nivel';
      // }

      print('🟢 [RoutineService] GET $endpoint');
      print('📋 [RoutineService] Filtro por nivel: TODOS');

      final response = await _apiService.get(endpoint);

      print('✅ [RoutineService] Response status: ${response.statusCode}');
      print('📊 [RoutineService] Response data:');
      print(response.data);

      if (response.data is List) {
        final rutinas =
            (response.data as List)
                .map((e) => RoutineListDto.fromJson(e))
                .toList();
        print('✅ [RoutineService] ${rutinas.length} rutinas cargadas');
        return rutinas;
      } else {
        print(
          '❌ [RoutineService] RESPUESTA INESPERADA: expected List, got  [${response.data.runtimeType}',
        );
        print('❌ [RoutineService] Contenido: ${response.data}');
        return [];
      }
    } catch (e) {
      print('❌ [RoutineService] ERROR obteniendo rutinas: $e');
      if (e.toString().contains('404')) {
        print(
          '📝 [RoutineService] Endpoint /planning/v1/routines no encontrado en backend',
        );
      } else if (e.toString().contains('401')) {
        print('📝 [RoutineService] Token de autenticación inválido o expirado');
      } else if (e.toString().contains('403')) {
        print('📝 [RoutineService] Sin permisos para consultar rutinas');
      }
      rethrow;
    }
  }

  /// Obtener detalle completo de una rutina (incluye ejercicios)
  Future<RoutineDetailDto> getRoutineDetail(String id) async {
    try {
      print('🟢 [RoutineService] GET /planning/v1/routines/$id');
      print('📋 [RoutineService] Obteniendo detalle para rutina ID: $id');

      final response = await _apiService.get('/planning/v1/routines/$id');

      print('✅ [RoutineService] Response status: ${response.statusCode}');
      print('📊 [RoutineService] Response data:');
      print(response.data);

      final rutina = RoutineDetailDto.fromJson(response.data);
      print('✅ [RoutineService] Rutina detalle cargada: ${rutina.nombre}');
      print(
        '📋 [RoutineService] Ejercicios incluidos: ${rutina.ejercicios.length}',
      );

      return rutina;
    } catch (e) {
      print('❌ [RoutineService] ERROR obteniendo detalle de rutina: $e');
      if (e.toString().contains('404')) {
        print('📝 [RoutineService] Rutina con ID $id no encontrada');
      }
      rethrow;
    }
  }

  /// Crear nueva rutina
  Future<String> createRoutine(Map<String, dynamic> routine) async {
    try {
      print('🟢 [RoutineService] POST /planning/v1/routines');
      print('📋 [RoutineService] Creando rutina: ${routine['nombre']}');
      print('📊 [RoutineService] Payload completo:');
      print(routine);

      // Asegurar que sportId sea 1 (Boxeo)
      routine['sportId'] = 1;

      final response = await _apiService.post(
        '/planning/v1/routines',
        data: routine,
      );

      print('✅ [RoutineService] Response status: ${response.statusCode}');
      print('📊 [RoutineService] Response data:');
      print(response.data);

      final rutinaId = response.data['id'] as String;
      print(
        '✅ [RoutineService] Rutina creada exitosamente: ${routine['nombre']}',
      );
      print('📋 [RoutineService] ID generado: $rutinaId');

      return rutinaId;
    } catch (e) {
      print('❌ [RoutineService] ERROR creando rutina: $e');
      if (e.toString().contains('422')) {
        print(
          '📝 [RoutineService] Datos de rutina inválidos - revisar estructura',
        );
      } else if (e.toString().contains('403')) {
        print(
          '📝 [RoutineService] Sin permisos para crear rutinas (solo entrenadores)',
        );
      }
      rethrow;
    }
  }

  /// Actualizar rutina existente
  Future<RoutineDetailDto> updateRoutine(
    String id,
    Map<String, dynamic> routine,
  ) async {
    try {
      print('🟢 [RoutineService] PUT /planning/v1/routines/$id');
      print('📋 [RoutineService] Actualizando rutina ID: $id');
      print('📊 [RoutineService] Payload:');
      print(routine);

      final response = await _apiService.request(
        'PUT',
        '/planning/v1/routines/$id',
        data: routine,
      );

      print('✅ [RoutineService] Response status: ${response.statusCode}');
      print('📊 [RoutineService] Response data:');
      print(response.data);

      final rutinaActualizada = RoutineDetailDto.fromJson(response.data);
      print(
        '✅ [RoutineService] Rutina actualizada: ${rutinaActualizada.nombre}',
      );

      return rutinaActualizada;
    } catch (e) {
      print('❌ [RoutineService] ERROR actualizando rutina: $e');
      if (e.toString().contains('404')) {
        print('📝 [RoutineService] Rutina con ID $id no encontrada');
      } else if (e.toString().contains('403')) {
        print('📝 [RoutineService] Sin permisos para actualizar esta rutina');
      }
      rethrow;
    }
  }

  /// Eliminar rutina
  Future<void> deleteRoutine(String id) async {
    try {
      print('🟢 [RoutineService] DELETE /planning/v1/routines/$id');
      print('📋 [RoutineService] Eliminando rutina ID: $id');

      final response = await _apiService.request(
        'DELETE',
        '/planning/v1/routines/$id',
      );

      print('✅ [RoutineService] Response status: ${response.statusCode}');
      print('📊 [RoutineService] Response data:');
      print(response.data);
      print('✅ [RoutineService] Rutina eliminada exitosamente');
    } catch (e) {
      print('❌ [RoutineService] ERROR eliminando rutina: $e');
      if (e.toString().contains('404')) {
        print('📝 [RoutineService] Rutina con ID $id no encontrada');
      } else if (e.toString().contains('403')) {
        print('📝 [RoutineService] Sin permisos para eliminar esta rutina');
      }
      rethrow;
    }
  }
}
