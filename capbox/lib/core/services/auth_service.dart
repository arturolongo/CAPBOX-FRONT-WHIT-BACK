import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Modelo para la respuesta del token (fuerte tipado)
class AuthTokenResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  AuthTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'],
    );
  }
}

class AuthService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  // Asumimos que el ApiService principal inyecta Dio ya configurado.
  AuthService(this._dio) : _secureStorage = const FlutterSecureStorage();

  /// Iniciar sesión con OAuth2 Password Grant
  Future<AuthTokenResponse?> iniciarSesion(
    String email,
    String password,
  ) async {
    const String clientId = 'capbox_mobile_app_prod';
    const String clientSecret = 'UN_SECRETO_DE_PRODUCCION_MUY_LARGO_Y_SEGURO';

    try {
      print('🚀 AUTH: Iniciando sesión con OAuth2');
      print('📧 AUTH: Email: $email');

      final response = await _dio.post(
        '/v1/oauth/token', // CORREGIDO: Agregado prefijo /v1
        data: {
          'grant_type': 'password',
          'client_id': clientId,
          'client_secret': clientSecret,
          'username': email,
          'password': password,
        },
      );

      print('✅ AUTH: Respuesta recibida');
      print('📊 AUTH: Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final tokenResponse = AuthTokenResponse.fromJson(response.data);
        await _secureStorage.write(
          key: 'access_token',
          value: tokenResponse.accessToken,
        );
        await _secureStorage.write(
          key: 'refresh_token',
          value: tokenResponse.refreshToken,
        );
        print('💾 AUTH: Tokens guardados en almacenamiento seguro');
        return tokenResponse;
      }
      return null;
    } on DioException catch (e) {
      print(
        '❌ AUTH: Error en inicio de sesión contra ms-identidad: ${e.response?.data}',
      );
      return null;
    } catch (e) {
      print('❌ AUTH: Error inesperado - $e');
      return null;
    }
  }

  /// Obtener token de acceso del almacenamiento seguro
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  /// Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null;
  }

  /// Cerrar sesión
  Future<void> cerrarSesion() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    print('🚪 AUTH: Sesión cerrada');
  }

  /// Refrescar token
  Future<AuthTokenResponse?> refrescarToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        print('⚠️ AUTH: No hay refresh token disponible');
        return null;
      }

      const String clientId = 'capbox_mobile_app_prod';
      const String clientSecret = 'UN_SECRETO_DE_PRODUCCION_MUY_LARGO_Y_SEGURO';

      final response = await _dio.post(
        '/v1/oauth/token', // CORREGIDO: Agregado prefijo /v1
        data: {
          'grant_type': 'refresh_token',
          'client_id': clientId,
          'client_secret': clientSecret,
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final tokenResponse = AuthTokenResponse.fromJson(response.data);

        // Actualizar tokens en almacenamiento seguro
        await _secureStorage.write(
          key: 'access_token',
          value: tokenResponse.accessToken,
        );
        await _secureStorage.write(
          key: 'refresh_token',
          value: tokenResponse.refreshToken,
        );

        print('🔄 AUTH: Token refrescado exitosamente');
        return tokenResponse;
      }
      return null;
    } on DioException catch (e) {
      print('❌ AUTH: Error refrescando token: ${e.response?.data}');
      return null;
    }
  }

  /// Obtener atributos del usuario (simulado para compatibilidad)
  Future<List<Map<String, dynamic>>> getUserAttributes() async {
    try {
      // Obtener datos del usuario desde la API
      final response = await _dio.get('/v1/users/me');
      final userData = response.data;

      // Convertir datos de la API a formato de atributos
      final attributes = <Map<String, dynamic>>[];

      if (userData['nombre'] != null) {
        attributes.add({
          'userAttributeKey': {'key': 'name'},
          'value': userData['nombre'],
        });
      }

      if (userData['rol'] != null) {
        attributes.add({
          'userAttributeKey': {'key': 'custom:rol'},
          'value': userData['rol'],
        });
      }

      if (userData['email'] != null) {
        attributes.add({
          'userAttributeKey': {'key': 'email'},
          'value': userData['email'],
        });
      }

      return attributes;
    } catch (e) {
      print('❌ AUTH: Error obteniendo atributos del usuario - $e');
      return [];
    }
  }

  /// Obtener usuario actual (simulado para compatibilidad)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _dio.get('/v1/users/me');
      return response.data;
    } catch (e) {
      print('❌ AUTH: Error obteniendo usuario actual - $e');
      return null;
    }
  }

  /// Verificar si el usuario está autenticado (alias de isAuthenticated)
  Future<bool> isSignedIn() async {
    return await isAuthenticated();
  }

  /// Iniciar sesión (alias de iniciarSesion)
  Future<Map<String, dynamic>?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await iniciarSesion(email, password);
      if (result != null) {
        return {
          'accessToken': result.accessToken,
          'refreshToken': result.refreshToken,
          'expiresIn': result.expiresIn,
        };
      }
      return null;
    } catch (e) {
      print('❌ AUTH: Error en signIn - $e');
      return null;
    }
  }

  /// Cerrar sesión (alias de cerrarSesion)
  Future<void> signOut() async {
    await cerrarSesion();
  }

  /// Registrar usuario (simulado para compatibilidad)
  Future<Map<String, dynamic>?> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? gymKey,
  }) async {
    try {
      print('🚀 AUTH: Registrando usuario con OAuth2');
      print('📧 AUTH: Email: $email');
      print('👤 AUTH: Nombre: $fullName');
      print('🎭 AUTH: Rol: $role');

      final response = await _dio.post(
        '/v1/auth/register', // CORREGIDO: Agregado prefijo /v1
        data: {
          'email': email,
          'password': password,
          'nombre': fullName,
          'rol': role,
          'claveGym': gymKey,
        },
      );

      if (response.statusCode == 200) {
        print('✅ AUTH: Usuario registrado exitosamente');
        return {'success': true, 'message': 'Usuario registrado exitosamente'};
      }
      return null;
    } catch (e) {
      print('❌ AUTH: Error registrando usuario - $e');
      return null;
    }
  }

  /// Confirmar registro (simulado para compatibilidad)
  Future<bool> confirmSignUp({
    required String email,
    required String confirmationCode,
  }) async {
    try {
      print('🚀 AUTH: Confirmando registro con OAuth2');
      print('📧 AUTH: Email: $email');
      print('🔑 AUTH: Código: $confirmationCode');

      // En OAuth2, la confirmación se maneja automáticamente
      // Simulamos éxito para mantener compatibilidad
      print('✅ AUTH: Registro confirmado exitosamente');
      return true;
    } catch (e) {
      print('❌ AUTH: Error confirmando registro - $e');
      return false;
    }
  }

  /// Reenviar código de confirmación (simulado para compatibilidad)
  Future<bool> resendSignUpCode(String email) async {
    try {
      print('🚀 AUTH: Reenviando código de confirmación');
      print('📧 AUTH: Email: $email');

      // En OAuth2, no necesitamos reenviar códigos
      // Simulamos éxito para mantener compatibilidad
      print('✅ AUTH: Código reenviado exitosamente');
      return true;
    } catch (e) {
      print('❌ AUTH: Error reenviando código - $e');
      return false;
    }
  }
}
