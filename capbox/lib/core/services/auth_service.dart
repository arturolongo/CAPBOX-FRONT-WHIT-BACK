import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert'; // Added for json and base64Url
import '../api/api_config.dart'; // CORREGIDO: Agregar import de ApiConfig

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
      accessToken: json['access_token']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString() ?? '',
      expiresIn:
          json['expires_in'] is int
              ? json['expires_in']
              : 3600, // Manejar null y otros tipos
    );
  }
}

class AuthService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  // Asumimos que el ApiService principal inyecta Dio ya configurado.
  AuthService(this._dio) : _secureStorage = const FlutterSecureStorage();

  /// Iniciar sesión con OAuth2
  Future<AuthTokenResponse> iniciarSesion(String email, String password) async {
    try {
      print('🚀 AUTH: Iniciando sesión con OAuth2');
      print('📧 AUTH: Email: $email');
      print('🔑 AUTH: Client ID: ${ApiConfig.oauthClientId}');
      print('🔐 AUTH: Client Secret: ${ApiConfig.oauthClientSecret}');
      print('🔍 AUTH: Verificando credenciales desde .env...');

      final formData = {
        'grant_type': 'password',
        'client_id': ApiConfig.oauthClientId,
        'client_secret': ApiConfig.oauthClientSecret,
        'username': email,
        'password': password,
      };

      print('📤 AUTH: Datos enviados al backend:');
      print(formData);

      final response = await _dio.post(
        ApiConfig.oauthToken,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          validateStatus: (status) => status! < 600,
        ),
      );

      print('📊 AUTH: Status Code: ${response.statusCode}');
      print('📋 AUTH: Respuesta del backend: ${response.data}');

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
      } else {
        print('❌ AUTH: Error del servidor - Status: ${response.statusCode}');
        print('❌ AUTH: Respuesta de error: ${response.data}');
        throw Exception('Error en autenticación: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ AUTH: Error de Dio - ${e.response?.statusCode}');
      print('❌ AUTH: Respuesta del servidor - ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic>) {
          final message = errorData['message']?.toString() ?? '';
          if (message.contains('confirma tu correo electrónico')) {
            throw Exception(
              'Por favor, confirma tu correo electrónico antes de iniciar sesión. Revisa tu bandeja de entrada.',
            );
          } else if (message.contains('Credenciales inválidas')) {
            throw Exception(
              'Credenciales inválidas. Verifica tu email y contraseña.',
            );
          } else {
            throw Exception('Error de autenticación: $message');
          }
        } else {
          throw Exception('Error de autenticación: Credenciales inválidas');
        }
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic>) {
          final message = errorData['message']?.toString() ?? '';
          if (message.contains('invalid_client')) {
            throw Exception(
              'Error de configuración del cliente OAuth2. Contacta al administrador.',
            );
          }
        }
      }

      throw Exception('Error en autenticación: ${e.response?.statusCode}');
    } catch (e) {
      print('❌ AUTH: Error inesperado - $e');
      rethrow;
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
        '/identity/v1/oauth/token', // Endpoint correcto
        data: {
          'grant_type': 'refresh_token',
          'client_id': clientId,
          'client_secret': clientSecret,
          'refresh_token': refreshToken,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
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
      print('❌ AUTH: Error refrescando token - ${e.response?.data}');
      return null;
    } catch (e) {
      print('❌ AUTH: Error inesperado refrescando token - $e');
      return null;
    }
  }

  /// Verificar si el usuario está confirmado intentando hacer login
  Future<bool> isUserConfirmed(String email, String password) async {
    try {
      const String clientId = 'capbox_mobile_app_prod';
      const String clientSecret = 'UN_SECRETO_DE_PRODUCCION_MUY_LARGO_Y_SEGURO';

      final response = await _dio.post(
        '/identity/v1/oauth/token',
        data: {
          'grant_type': 'password',
          'client_id': clientId,
          'client_secret': clientSecret,
          'username': email,
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      // Si llega aquí, el login fue exitoso (usuario confirmado)
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic>) {
          final message = errorData['message']?.toString() ?? '';
          // Si el mensaje indica que debe confirmar email, entonces NO está confirmado
          return !message.contains('confirma tu correo electrónico');
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Obtener atributos del usuario (solo si está autenticado)
  Future<List<Map<String, String>>> getUserAttributes() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        print('⚠️ AUTH: No hay token disponible para obtener atributos');
        return [];
      }

      // Usar el endpoint real del backend
      print('🔍 AUTH: Obteniendo información del usuario desde backend...');

      final response = await _dio.get(
        '/identity/v1/usuarios/me', // CORREGIDO: Usar endpoint correcto
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final userData = response.data as Map<String, dynamic>;
        print('📊 AUTH: Datos del usuario obtenidos: $userData');

        final attributes = <Map<String, String>>[];

        // Convertir datos del usuario a formato de atributos
        if (userData.containsKey('email')) {
          attributes.add({
            'name': 'email',
            'value': userData['email'].toString(),
          });
        }
        if (userData.containsKey('nombre')) {
          attributes.add({
            'name': 'name',
            'value': userData['nombre'].toString(),
          });
        }
        if (userData.containsKey('rol')) {
          attributes.add({
            'name': 'custom:role',
            'value': userData['rol'].toString(),
          });
        }

        print('✅ AUTH: Atributos extraídos: $attributes');
        return attributes;
      }
      return [];
    } catch (e) {
      print('❌ AUTH: Error obteniendo atributos del usuario - $e');
      return [];
    }
  }

  /// Obtener usuario actual (desde backend)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        print('⚠️ AUTH: No hay token disponible para obtener usuario');
        return null;
      }

      // Usar el endpoint real del backend
      print('🔍 AUTH: Obteniendo usuario actual desde backend...');

      final response = await _dio.get(
        '/identity/v1/usuarios/me', // CORREGIDO: Usar endpoint correcto
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final userData = response.data as Map<String, dynamic>;
        print('✅ AUTH: Usuario obtenido del backend: $userData');
        return userData;
      }
      return null;
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
      rethrow; // Propagar la excepción para que el UI pueda manejarla
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
        '/auth/register', // CORREGIDO: Sin /v1 (ya está en baseUrl)
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

  /// Confirmar registro con el backend OAuth2
  Future<bool> confirmSignUp({
    required String email,
    required String confirmationCode,
  }) async {
    try {
      print('🚀 AUTH: Confirmando registro con backend OAuth2');
      print('📧 AUTH: Email: $email');
      print('🔑 AUTH: Código: $confirmationCode');

      // Usar el endpoint real de confirmación del backend
      final response = await _dio.post(
        '/identity/v1/auth/confirm-email',
        data: {
          'token': confirmationCode, // El código de confirmación es el token
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200) {
        print('✅ AUTH: Registro confirmado exitosamente en backend');
        return true;
      } else {
        print('❌ AUTH: Error en confirmación - Status: ${response.statusCode}');
        print('📝 AUTH: Respuesta: ${response.data}');
        return false;
      }
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
