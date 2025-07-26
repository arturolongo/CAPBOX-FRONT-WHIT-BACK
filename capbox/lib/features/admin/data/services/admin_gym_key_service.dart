import '../../../../core/services/aws_api_service.dart';

/// Servicio para que el admin gestione la clave del gimnasio
class AdminGymKeyService {
  final AWSApiService _apiService;

  AdminGymKeyService(this._apiService);

  /// Obtener la clave actual del gimnasio (SIN MOCK - ERROR REAL)
  Future<String> getGymKey() async {
    try {
      print(
        '🗝️ ADMIN: Obteniendo clave del gimnasio desde /v1/users/me/gym/key',
      );

      final response = await _apiService.getAdminGymKey();

      final key =
          response.data['claveGym'] ?? // Formato v1.4.5
          response.data['claveGimnasio'] ?? // Formato anterior
          response.data['gymKey']; // Formato alternativo

      if (key == null || key.isEmpty) {
        throw Exception('Clave del gimnasio no encontrada en respuesta');
      }

      print('✅ ADMIN: Clave obtenida - $key');
      return key;
    } catch (e) {
      print('❌ ADMIN: Error obteniendo clave - $e');
      // SIN MOCK - Lanzar error real para que UI lo maneje
      rethrow;
    }
  }

  /// Actualizar la clave del gimnasio
  Future<void> updateGymKey(String newKey) async {
    try {
      print('🗝️ ADMIN: Actualizando clave del gimnasio a: $newKey');

      await _apiService.updateAdminGymKey(newKey);

      print('✅ ADMIN: Clave actualizada exitosamente');
    } catch (e) {
      print('❌ ADMIN: Error actualizando clave - $e');
      rethrow;
    }
  }

  /// Generar una nueva clave automática (formato libre con mayúscula y número)
  String generateNewKey() {
    final random = DateTime.now().millisecondsSinceEpoch.remainder(9999) + 1000;
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final randomLetter = letters[(random % 26)];

    // Formato: Gym + letra + números (ej: GymA1234)
    return 'Gym$randomLetter$random';
  }
}
