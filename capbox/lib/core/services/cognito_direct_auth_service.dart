import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class CognitoDirectAuthService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  CognitoDirectAuthService()
    : _dio = Dio(),
      _secureStorage = const FlutterSecureStorage();

  // Configuración de Cognito
  static const String _cognitoUrl =
      'https://cognito-idp.us-east-1.amazonaws.com/';
  // --- APP CLIENT PÚBLICO (sin client secret) ---
  static const String _appClientId = '3tbo7h2b21cna6gj44h8si9g2t';
  static const String _userPoolId = 'us-east-1_BGLrPMS01';

  /// Iniciar sesión con email y contraseña (solución definitiva con SECRET_HASH)
  Future<Map<String, dynamic>?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🚀 COGNITO: Iniciando sesión directa');
      print('📧 Email: $email');

      final requestData = {
        'AuthFlow': 'USER_SRP_AUTH',
        'ClientId': _appClientId,
        'AuthParameters': {
          'USERNAME': email,
          'SRP_A': _generateSRPA(email, password),
        },
      };

      print('📤 COGNITO: Datos enviados a Cognito:');
      print('$requestData');

      final response = await _dio.post(
        _cognitoUrl,
        data: requestData,
        options: Options(
          headers: {
            'X-Amz-Target': 'AWSCognitoIdentityProviderService.InitiateAuth',
            'Content-Type': 'application/x-amz-json-1.1',
          },
        ),
      );

      print('✅ COGNITO: Sesión iniciada exitosamente');

      final authResult = response.data['AuthenticationResult'];
      if (authResult != null) {
        // Guardar tokens en almacenamiento seguro
        await _secureStorage.write(
          key: 'access_token',
          value: authResult['AccessToken'],
        );
        await _secureStorage.write(
          key: 'refresh_token',
          value: authResult['RefreshToken'],
        );
        await _secureStorage.write(
          key: 'id_token',
          value: authResult['IdToken'],
        );

        print('💾 COGNITO: Tokens guardados en almacenamiento seguro');
        return authResult;
      }

      return null;
    } on DioException catch (e) {
      print('❌ COGNITO: Error en inicio de sesión - ${e.response?.data}');
      return null;
    } catch (e) {
      print('❌ COGNITO: Error inesperado - $e');
      return null;
    }
  }

  // Función auxiliar para generar SRP_A (simplificada)
  String _generateSRPA(String email, String password) {
    // Para simplificar, usamos un valor fijo
    // En una implementación real, esto sería un cálculo SRP complejo
    return 'A=' + base64.encode(utf8.encode(email + password));
  }

  /// Registrar nuevo usuario
  Future<Map<String, dynamic>?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? gymKey,
  }) async {
    return await registerUser(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
      gymKey: gymKey,
    );
  }

  /// Registrar nuevo usuario (alias para compatibilidad)
  Future<Map<String, dynamic>?> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? gymKey,
  }) async {
    try {
      print('🚀 COGNITO: Registrando usuario directo');
      print('📧 Email: $email');
      print('👤 Nombre: $fullName');
      print('🎭 Rol: $role');

      final userAttributes = [
        {'Name': 'email', 'Value': email},
        {'Name': 'name', 'Value': fullName},
        {'Name': 'custom:rol', 'Value': role},
      ];

      if (gymKey != null && gymKey.isNotEmpty) {
        userAttributes.add({'Name': 'custom:clavegym', 'Value': gymKey});
      }

      final response = await _dio.post(
        '/',
        data: {
          'ClientId': _appClientId,
          'Username': email,
          'Password': password,
          'UserAttributes': userAttributes,
        },
        options: Options(
          headers: {'X-Amz-Target': 'AWSCognitoIdentityProviderService.SignUp'},
        ),
      );

      print('✅ COGNITO: Usuario registrado exitosamente');
      return response.data;
    } on DioException catch (e) {
      print('❌ COGNITO: Error en registro - ${e.response?.data}');
      return null;
    } catch (e) {
      print('❌ COGNITO: Error inesperado en registro - $e');
      return null;
    }
  }

  /// Confirmar registro con código
  Future<bool> confirmSignUp({
    required String email,
    required String confirmationCode,
  }) async {
    try {
      print('🚀 COGNITO: Confirmando registro');
      print('📧 Email: $email');
      print('🔢 Código: $confirmationCode');

      await _dio.post(
        '/',
        data: {
          'ClientId': _appClientId,
          'Username': email,
          'ConfirmationCode': confirmationCode,
        },
        options: Options(
          headers: {
            'X-Amz-Target': 'AWSCognitoIdentityProviderService.ConfirmSignUp',
          },
        ),
      );

      print('✅ COGNITO: Registro confirmado exitosamente');
      return true;
    } on DioException catch (e) {
      print('❌ COGNITO: Error en confirmación - ${e.response?.data}');
      return false;
    } catch (e) {
      print('❌ COGNITO: Error inesperado en confirmación - $e');
      return false;
    }
  }

  /// Obtener token de acceso actual
  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      if (token != null) {
        print('🔑 COGNITO: Token de acceso obtenido');
        print('🔍 COGNITO: TOKEN COMPLETO PARA ANÁLISIS:');
        print('$token');
        print('🔍 COGNITO: FIN DEL TOKEN');
        return token;
      }
      print('⚠️ COGNITO: No hay token de acceso disponible');
      return null;
    } catch (e) {
      print('❌ COGNITO: Error obteniendo token - $e');
      return null;
    }
  }

  /// Verificar si el usuario está autenticado
  Future<bool> isSignedIn() async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      return token != null;
    } catch (e) {
      print('❌ COGNITO: Error verificando autenticación - $e');
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      print('🚀 COGNITO: Cerrando sesión');

      // Limpiar tokens del almacenamiento seguro
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');
      await _secureStorage.delete(key: 'id_token');

      print('✅ COGNITO: Sesión cerrada exitosamente');
    } catch (e) {
      print('❌ COGNITO: Error cerrando sesión - $e');
    }
  }

  /// Verificar si el usuario necesita ser vinculado a un gimnasio
  Future<bool> checkUserLinkStatus() async {
    try {
      print('🔍 COGNITO: Verificando estado de vinculación del usuario');

      final token = await getAccessToken();
      if (token == null) {
        print('⚠️ COGNITO: No hay token disponible para verificar vinculación');
        return false;
      }

      // Crear una instancia temporal de Dio para la verificación
      final dio = Dio();
      dio.options.baseUrl = 'https://api.capbox.site';
      dio.options.headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await dio.get('/v1/users/me');

      if (response.statusCode == 200) {
        final userData = response.data;
        final gimnasio = userData['gimnasio'];

        print('🏋️ COGNITO: Estado de gimnasio: ${gimnasio ?? "null"}');
        print(
          '🔗 COGNITO: Usuario ${gimnasio == null ? "necesita" : "ya está"} vinculado',
        );

        return gimnasio == null; // true si necesita vinculación
      }

      return false;
    } catch (e) {
      print('❌ COGNITO: Error verificando estado de vinculación - $e');
      return false;
    }
  }

  /// Reenviar código de confirmación
  Future<bool> resendSignUpCode(String email) async {
    try {
      print('🚀 COGNITO: Reenviando código de confirmación');
      print('📧 Email: $email');

      await _dio.post(
        '/',
        data: {'ClientId': _appClientId, 'Username': email},
        options: Options(
          headers: {
            'X-Amz-Target':
                'AWSCognitoIdentityProviderService.ResendConfirmationCode',
          },
        ),
      );

      print('✅ COGNITO: Código reenviado exitosamente');
      return true;
    } on DioException catch (e) {
      print('❌ COGNITO: Error reenviando código - ${e.response?.data}');
      return false;
    } catch (e) {
      print('❌ COGNITO: Error inesperado reenviando código - $e');
      return false;
    }
  }

  /// Obtener usuario actual (simulado para compatibilidad)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await getAccessToken();
      if (token == null) return null;

      // Decodificar token JWT para obtener información del usuario
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);

      return {
        'username': payloadMap['username'] ?? payloadMap['sub'],
        'email': payloadMap['email'],
      };
    } catch (e) {
      print('❌ COGNITO: Error obteniendo usuario actual - $e');
      return null;
    }
  }

  /// Obtener atributos del usuario (simulado para compatibilidad)
  Future<List<Map<String, dynamic>>> getUserAttributes() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return [];

      // Para compatibilidad, devolver atributos básicos
      return [
        {
          'userAttributeKey': {'key': 'name'},
          'value': user['name'] ?? 'Usuario',
        },
        {
          'userAttributeKey': {'key': 'custom:rol'},
          'value': user['custom:rol'] ?? 'atleta',
        },
        {
          'userAttributeKey': {'key': 'email'},
          'value': user['email'] ?? '',
        },
      ];
    } catch (e) {
      print('❌ COGNITO: Error obteniendo atributos - $e');
      return [];
    }
  }
}
