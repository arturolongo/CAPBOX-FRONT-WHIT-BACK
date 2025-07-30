import '../../../../core/services/aws_api_service.dart';
import 'dart:math';

/// Servicio para que el admin gestione la clave del gimnasio
class AdminGymKeyService {
  final AWSApiService _apiService;

  AdminGymKeyService(this._apiService);

  /// Obtener la clave actual del gimnasio (SIN MOCK - ERROR REAL)
  Future<String> getGymKey() async {
    try {
      print('🗝️ ADMIN: Obteniendo clave del gimnasio desde /users/me/gym/key');

      final response = await _apiService.getAdminGymKey();

      // 🔧 CORRECCIÓN IMPLEMENTADA: Manejar diferentes formatos de respuesta
      final key =
          response.data['claveGym'] ?? // Formato v1.4.5
          response.data['claveGimnasio'] ?? // Formato anterior
          response.data['gymKey'] ?? // Formato alternativo
          response.data['clave']; // Formato nuevo

      if (key == null || key.isEmpty) {
        throw Exception('Clave del gimnasio no encontrada en respuesta');
      }

      print('✅ ADMIN: Clave obtenida - $key');
      return key;
    } catch (e) {
      print('❌ ADMIN: Error obteniendo clave - $e');
      // 🔧 CORRECCIÓN IMPLEMENTADA: Manejar errores específicos
      if (e.toString().contains('404')) {
        throw Exception(
          'No tienes un gimnasio asignado. Contacta al administrador.',
        );
      } else if (e.toString().contains('403')) {
        throw Exception('No tienes permisos para ver la clave del gimnasio.');
      }
      rethrow;
    }
  }

  /// Actualizar la clave del gimnasio
  Future<void> updateGymKey(String newKey) async {
    try {
      // ✅ VALIDACIÓN EN FRONTEND - Mínimo 8 caracteres
      if (newKey.length < 8) {
        throw Exception('La nueva clave debe tener al menos 8 caracteres');
      }

      // ✅ VALIDACIÓN DE FORMATO - Solo A-Z, 0-9, -, _
      if (!RegExp(r'^[A-Z0-9\-_]+$').hasMatch(newKey)) {
        throw Exception(
          'La clave solo puede contener letras mayúsculas, números, guiones y guiones bajos',
        );
      }

      print(
        '🗝️ ADMIN: Actualizando clave del gimnasio a: $newKey (${newKey.length} caracteres)',
      );

      await _apiService.updateAdminGymKey(newKey);

      print('✅ ADMIN: Clave actualizada exitosamente');
    } catch (e) {
      print('❌ ADMIN: Error actualizando clave - $e');
      rethrow;
    }
  }

  /// Generar una nueva clave basada en el nombre del gimnasio
  /// Formato: PRIMERAS_3_LETRAS + al menos 4 caracteres adicionales
  /// Ejemplo: "Zikar" -> "ZIK23hk", "Boxing Club" -> "BOX45mn"
  String generateNewKey(String gymName) {
    if (gymName.isEmpty) {
      throw ArgumentError('El nombre del gimnasio no puede estar vacío');
    }

    // Obtener las primeras 3 letras del nombre del gimnasio (en mayúsculas)
    final prefix = gymName.trim().toUpperCase().substring(0, 3);

    // Generar al menos 5 caracteres adicionales para cumplir mínimo 8 total
    final random = Random();
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final suffix = String.fromCharCodes(
      Iterable.generate(
        5 + random.nextInt(3), // Mínimo 5, máximo 8 caracteres adicionales
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );

    final newKey = '$prefix$suffix';
    print(
      '🗝️ ADMIN: Generando clave para gimnasio "$gymName" -> "$newKey" (${newKey.length} caracteres)',
    );

    // ✅ VERIFICAR que cumple con la validación del backend
    if (newKey.length < 8) {
      throw Exception(
        'Error generando clave: debe tener al menos 8 caracteres',
      );
    }

    return newKey;
  }

  /// Validar formato de clave según el nuevo estándar
  /// Debe tener: PRIMERAS_3_LETRAS + al menos 5 caracteres adicionales (mínimo 8 total)
  bool isValidKeyFormat(String key, String gymName) {
    if (key.isEmpty || gymName.isEmpty) return false;

    // Obtener las primeras 3 letras del nombre del gimnasio
    final expectedPrefix = gymName.trim().toUpperCase().substring(0, 3);

    // Verificar que la clave empiece con las 3 letras correctas
    if (!key.toUpperCase().startsWith(expectedPrefix)) {
      return false;
    }

    // ✅ VERIFICAR MÍNIMO 8 CARACTERES (validación del backend)
    if (key.length < 8) {
      return false;
    }

    // Verificar que después del prefijo tenga al menos 5 caracteres
    final suffix = key.substring(3);
    if (suffix.length < 5) {
      return false;
    }

    // ✅ VERIFICAR FORMATO (solo A-Z, 0-9, -, _)
    if (!RegExp(r'^[A-Z0-9\-_]+$').hasMatch(key)) {
      return false;
    }

    return true;
  }

  /// Obtener el prefijo esperado para un gimnasio
  String getExpectedPrefix(String gymName) {
    if (gymName.isEmpty) return '';
    return gymName.trim().toUpperCase().substring(0, 3);
  }

  /// Fix temporal para activar coaches existentes
  Future<Map<String, dynamic>> activarCoachesExistentes() async {
    try {
      print('🔧 ADMIN: Activando coaches existentes...');

      final response = await _apiService.post(
        '/identity/v1/usuarios/fix-coaches-estado',
        data: {},
      );

      print('✅ ADMIN: Coaches activados exitosamente');
      print('📊 ADMIN: Respuesta: ${response.data}');

      return response.data;
    } catch (e) {
      print('❌ ADMIN: Error activando coaches - $e');
      rethrow;
    }
  }

  /// Test para verificar si el endpoint del fix existe
  Future<bool> testEndpointFixCoaches() async {
    try {
      print('🧪 ADMIN: Probando endpoint fix-coaches-estado...');

      final response = await _apiService.post(
        '/identity/v1/usuarios/fix-coaches-estado',
        data: {},
      );

      print('✅ ADMIN: Endpoint existe y funciona');
      print('📊 ADMIN: Respuesta: ${response.data}');

      return true;
    } catch (e) {
      print('❌ ADMIN: Endpoint NO existe o error - $e');
      return false;
    }
  }
}
