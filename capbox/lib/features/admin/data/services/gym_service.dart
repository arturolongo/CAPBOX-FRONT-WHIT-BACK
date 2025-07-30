import 'package:dio/dio.dart';
import '../../../../core/services/aws_api_service.dart';
import '../dtos/gym_member_dto.dart';

/// Servicio para gestionar miembros del gimnasio
class GymService {
  final AWSApiService _apiService;

  GymService(this._apiService);

  /// Obtener todos los miembros del gimnasio actual
  Future<List<GymMemberDto>> getGymMembers() async {
    try {
      print('👥 GYM: Obteniendo miembros del gimnasio');

      // 🔧 CORRECCIÓN IMPLEMENTADA: Obtener gym ID según rol
      final userResponse = await _apiService.getUserMe();
      final userData = userResponse.data;

      String? gymId;

      // Para admins: usar ownedGym
      if (userData['rol'] == 'admin') {
        final ownedGym = userData['ownedGym'];
        if (ownedGym != null) {
          gymId = ownedGym['id'];
          print('👑 GYM: Admin usando ownedGym ID: $gymId');
        }
      } else {
        // Para coaches/atletas: usar gimnasio
        final gimnasio = userData['gimnasio'];
        if (gimnasio != null) {
          gymId = gimnasio['id'];
          print('👥 GYM: Usuario usando gimnasio ID: $gymId');
        }
      }

      if (gymId == null) {
        print('❌ GYM: Usuario no está vinculado a un gimnasio');
        return [];
      }

      print('🏋️ GYM: Usando Gym ID: $gymId');

      // PASO 2: Obtener miembros del gimnasio
      final response = await _apiService.getGymMembers(gymId);

      // 🔧 CORRECCIÓN IMPLEMENTADA: Diagnóstico actualizado
      print('🔍 GYM: === DIAGNÓSTICO DE RESPUESTA ===');
      print('📊 GYM: Status Code: ${response.statusCode}');
      print('📋 GYM: Respuesta completa: ${response.data}');

      if (response.data is List) {
        final membersList = response.data as List;
        print('👥 GYM: Total de miembros recibidos: ${membersList.length}');

        // Analizar cada miembro
        for (int i = 0; i < membersList.length; i++) {
          final member = membersList[i];
          print('👤 GYM: Miembro $i:');
          print('   ID: ${member['id']}');
          print('   Nombre: ${member['nombre'] ?? member['name']}');
          print('   Email: ${member['email']}');
          print('   Rol: ${member['rol'] ?? member['role']}');
          print('   Estado: ${member['estado'] ?? member['status']}');
        }
      } else {
        print(
          '⚠️ GYM: Respuesta no es una lista: ${response.data.runtimeType}',
        );
      }

      print('✅ GYM: Miembros obtenidos exitosamente');
      return (response.data as List)
          .map((json) => GymMemberDto.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ GYM: Error obteniendo miembros - $e');
      return [];
    }
  }

  /// Obtener solicitudes pendientes de aprobación (para admins)
  Future<List<GymMemberDto>> getPendingRequests() async {
    try {
      print('🏋️ GYM: Obteniendo solicitudes pendientes');

      final response = await _apiService.getPendingRequests();

      print('✅ GYM: ${response.data.length} solicitudes pendientes');

      return (response.data as List)
          .map((json) => GymMemberDto.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ GYM: Error obteniendo solicitudes - $e');
      rethrow;
    }
  }

  /// Aprobar un atleta con datos completos (físicos + tutor)
  Future<void> approveAthleteWithData({
    required String athleteId,
    required Map<String, dynamic> physicalData,
    required Map<String, dynamic> tutorData,
  }) async {
    try {
      print('🏋️ GYM: Aprobando atleta $athleteId con datos completos');
      print('🏋️ GYM: Datos físicos - $physicalData');
      print('🏋️ GYM: Datos tutor - $tutorData');

      // 🔧 SIMPLIFICADO: Usar método directo sin debug
      await _apiService.approveAthlete(
        athleteId: athleteId,
        physicalData: physicalData,
        tutorData: tutorData,
      );

      print('✅ GYM: Atleta aprobado exitosamente con datos completos');
    } catch (e) {
      print('❌ GYM: Error aprobando atleta - $e');
      rethrow;
    }
  }

  /// Buscar miembros por nombre
  Future<List<GymMemberDto>> searchMembers(String query) async {
    try {
      print('🏋️ GYM: Buscando miembros: "$query"');

      final allMembers = await getGymMembers();

      final filtered =
          allMembers
              .where(
                (member) =>
                    member.name.toLowerCase().contains(query.toLowerCase()) ||
                    member.email.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();

      print('✅ GYM: ${filtered.length} miembros encontrados');

      return filtered;
    } catch (e) {
      print('❌ GYM: Error buscando miembros - $e');
      rethrow;
    }
  }

  /// Obtener miembros por rol
  Future<List<GymMemberDto>> getMembersByRole(String role) async {
    try {
      print('🏋️ GYM: Obteniendo miembros con rol: $role');

      final allMembers = await getGymMembers();

      final filtered =
          allMembers
              .where(
                (member) => member.role.toLowerCase() == role.toLowerCase(),
              )
              .toList();

      print('✅ GYM: ${filtered.length} miembros con rol $role');

      return filtered;
    } catch (e) {
      print('❌ GYM: Error filtrando por rol - $e');
      rethrow;
    }
  }

  /// Obtener estudiantes (atletas) del gimnasio
  Future<List<GymMemberDto>> getStudents() async {
    return getMembersByRole('atleta');
  }

  /// Obtener entrenadores del gimnasio
  Future<List<GymMemberDto>> getCoaches() async {
    return getMembersByRole('entrenador');
  }
}
