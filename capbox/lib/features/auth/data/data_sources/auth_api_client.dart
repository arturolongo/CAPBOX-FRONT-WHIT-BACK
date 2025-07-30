import 'package:dio/dio.dart';
import '../../../../core/api/api_config.dart';
import '../dtos/oauth_token_request_dto.dart';
import '../dtos/oauth_token_response_dto.dart';
import '../dtos/register_request_dto.dart';
import '../dtos/user_profile_dto.dart';
import '../dtos/confirm_email_dto.dart';
import 'dart:convert'; // Added for json and base64Url

class AuthApiClient {
  final Dio _dio;

  AuthApiClient(this._dio);

  /// Generar email único para pruebas
  String generateTestEmail() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'test.$timestamp@example.com';
  }

  /// OAuth2 Login - Obtiene access_token y refresh_token
  Future<OAuthTokenResponseDto> login(OAuthTokenRequestDto dto) async {
    final response = await _dio.post(
      ApiConfig.getIdentidadUrl(ApiConfig.oauthToken),
      data: dto.toJson(),
    );
    return OAuthTokenResponseDto.fromJson(response.data);
  }

  /// Registro de nuevo usuario
  Future<RegisterResponseDto> register(RegisterRequestDto dto) async {
    try {
      print('🚀 AUTH API: Intentando registro con email: ${dto.email}');

      // Debuggear el JSON que se está enviando
      final jsonData = dto.toJson();
      print('📋 AUTH API: Datos enviados (raw): $jsonData');

      // Convertir a JSON string para verificar formato
      final jsonString = jsonData.toString();
      print('📋 AUTH API: JSON string: $jsonString');

      final response = await _dio.post(
        ApiConfig.getIdentidadUrl(ApiConfig.register),
        data: jsonData,
        options: Options(
          headers: ApiConfig.defaultHeaders,
          validateStatus:
              (status) =>
                  status! <
                  600, // Aceptar TODOS los códigos para capturar errores
        ),
      );

      print('✅ AUTH API: Registro exitoso');
      return RegisterResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ AUTH API: Error en registro - ${e.message}');
      print('📊 AUTH API: Status code: ${e.response?.statusCode}');

      // CAPTURAR MENSAJE DETALLADO DEL BACKEND (incluyendo 500)
      if (e.response?.data != null) {
        print('🔍 AUTH API: Error detallado del backend:');
        print(e.response!.data);

        // Extraer mensaje específico del backend
        final errorData = e.response!.data;
        String errorMessage = 'Error desconocido';

        if (errorData is Map<String, dynamic>) {
          // Manejar diferentes formatos de respuesta de error
          if (errorData.containsKey('message')) {
            if (errorData['message'] is List) {
              errorMessage = errorData['message'].join(', ');
            } else {
              errorMessage = errorData['message'].toString();
            }
          } else if (errorData.containsKey('error')) {
            errorMessage = errorData['error'].toString();
          } else {
            errorMessage = errorData.toString();
          }
        } else if (errorData is String) {
          errorMessage = errorData;
        } else if (errorData is List) {
          errorMessage = errorData.join(', ');
        }

        print('📝 AUTH API: Mensaje de error procesado: $errorMessage');

        // Lanzar excepción con mensaje específico del backend
        throw Exception(errorMessage);
      }

      // Manejo de errores por código de estado (fallback si no hay data)
      if (e.response?.statusCode == 500) {
        throw Exception(
          'Error del servidor (500): El backend está fallando. Contacta al administrador.',
        );
      } else if (e.response?.statusCode == 400) {
        throw Exception(
          'Datos inválidos: Verifica que todos los campos sean correctos.',
        );
      } else if (e.response?.statusCode == 422) {
        // Error específico para email ya registrado
        throw Exception(
          'Este correo electrónico ya está registrado. Por favor, intenta con otro.',
        );
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      print('❌ AUTH API: Error inesperado - $e');
      throw Exception('Error inesperado: $e');
    }
  }

  /// Probar flujo completo de registro con email único
  Future<void> testCompleteRegistrationFlow() async {
    try {
      // Generar email único
      final testEmail = generateTestEmail();
      print('🧪 AUTH API: Probando registro con email único: $testEmail');

      // Crear datos de prueba
      final testDto = RegisterRequestDto(
        email: testEmail,
        password: 'test123456',
        nombre: 'Usuario de Prueba',
        rol: RolUsuario.Atleta,
      );

      // Intentar registro
      final response = await register(testDto);

      print('✅ AUTH API: Registro exitoso!');
      print('📧 AUTH API: Email registrado: ${response.data.email}');
      print('🆔 AUTH API: ID del usuario: ${response.data.id}');
      print(
        '📬 AUTH API: Revisa la bandeja de entrada de $testEmail para el email de confirmación',
      );
    } catch (e) {
      print('❌ AUTH API: Error en flujo de prueba - $e');
      rethrow;
    }
  }

  /// Obtener perfil del usuario autenticado
  Future<UserProfileDto> getUserProfile(String token) async {
    final response = await _dio.get(
      ApiConfig.getIdentidadUrl(ApiConfig.userProfile),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return UserProfileDto.fromJson(response.data);
  }

  /// Refresh token cuando expire el access_token
  Future<OAuthTokenResponseDto> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      ApiConfig.getIdentidadUrl(ApiConfig.oauthToken),
      data: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': ApiConfig.oauthClientId,
        'client_secret': ApiConfig.oauthClientSecret,
      },
    );
    return OAuthTokenResponseDto.fromJson(response.data);
  }

  /// Obtener solicitudes pendientes (para entrenadores)
  Future<List<Map<String, dynamic>>> getPendingRequests(String token) async {
    final response = await _dio.get(
      ApiConfig.getIdentidadUrl(ApiConfig.pendingRequests),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Aprobar atleta (para entrenadores)
  Future<Map<String, dynamic>> approveAthlete(
    String athleteId,
    String token,
  ) async {
    final response = await _dio.post(
      ApiConfig.getIdentidadUrl(ApiConfig.approveAthlete(athleteId)),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  /// Obtener miembros del gimnasio (para entrenadores)
  Future<List<Map<String, dynamic>>> getGymMembers(
    String gymId,
    String token,
  ) async {
    final response = await _dio.get(
      ApiConfig.getIdentidadUrl(ApiConfig.gymMembersByGym(gymId)),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Método de prueba simple para diagnóstico desde consola
  Future<void> testDiagnosis() async {
    final testEmail = generateTestEmail();
    final testPassword = 'test123456';

    print('🧪 AUTH API: Iniciando prueba de diagnóstico...');
    print('📧 Email de prueba: $testEmail');
    print('🔑 Password de prueba: $testPassword');

    await diagnoseRegistrationFlow(testEmail, testPassword);
  }

  /// Diagnóstico completo del flujo de registro y confirmación
  Future<void> diagnoseRegistrationFlow(String email, String password) async {
    try {
      print('🔬 AUTH API: === DIAGNÓSTICO COMPLETO ===');
      print('📧 Email: $email');
      print('🔑 Password: $password');

      // PASO 1: Verificar si el usuario ya existe
      print('\n🔍 PASO 1: Verificando si usuario existe...');
      final confirmationStatus = await checkUserConfirmationStatus(
        email,
        password,
      );
      print('📊 Estado de confirmación: $confirmationStatus');

      // PASO 2: Intentar registro (puede fallar si ya existe)
      print('\n🚀 PASO 2: Intentando registro...');
      try {
        final testDto = RegisterRequestDto(
          email: email,
          password: password,
          nombre: 'Usuario de Prueba',
          rol: RolUsuario.Atleta,
        );

        final registerResponse = await register(testDto);
        print('✅ Registro exitoso: ${registerResponse.data.email}');
        print('📧 Email registrado: ${registerResponse.data.email}');
        print('🆔 ID del usuario: ${registerResponse.data.id}');
        print(
          '📬 Revisa la bandeja de entrada de $email para el email de confirmación',
        );
      } catch (e) {
        print('❌ Error en registro: $e');
        if (e.toString().contains('ya está registrado')) {
          print('ℹ️ El usuario ya existe, continuando con verificación...');
        }
      }

      // PASO 3: Verificar estado después del registro
      print('\n🔍 PASO 3: Verificando estado después del registro...');
      final statusAfterRegister = await checkUserConfirmationStatus(
        email,
        password,
      );
      print('📊 Estado después del registro: $statusAfterRegister');

      // PASO 4: Intentar login real
      print('\n🔐 PASO 4: Intentando login real...');
      try {
        const String clientId = 'capbox_mobile_app_prod';
        const String clientSecret =
            'UN_SECRETO_DE_PRODUCCION_MUY_LARGO_Y_SEGURO';

        final loginResponse = await _dio.post(
          ApiConfig.getIdentidadUrl(ApiConfig.oauthToken),
          data: {
            'grant_type': 'password',
            'client_id': clientId,
            'client_secret': clientSecret,
            'username': email,
            'password': password,
          },
          options: Options(
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            validateStatus: (status) => status! < 600,
          ),
        );

        if (loginResponse.statusCode == 200) {
          print('✅ Login exitoso!');
          print(
            '🎫 Access Token: ${loginResponse.data['access_token']?.toString().substring(0, 20)}...',
          );
          print(
            '🔄 Refresh Token: ${loginResponse.data['refresh_token']?.toString().substring(0, 20)}...',
          );
        } else {
          print('❌ Login fallido');
          print('📊 Status: ${loginResponse.statusCode}');
          print('📝 Mensaje: ${loginResponse.data}');
        }
      } catch (e) {
        print('❌ Error en login: $e');
      }

      print('\n🔬 AUTH API: === FIN DEL DIAGNÓSTICO ===');
    } catch (e) {
      print('❌ AUTH API: Error en diagnóstico - $e');
    }
  }

  /// Verificar estado de confirmación de un usuario
  Future<Map<String, dynamic>> checkUserConfirmationStatus(
    String email,
    String password,
  ) async {
    try {
      print('🔍 AUTH API: Verificando estado de confirmación para: $email');

      // Intentar hacer login para verificar si está confirmado
      const String clientId = 'capbox_mobile_app_prod';
      const String clientSecret = 'UN_SECRETO_DE_PRODUCCION_MUY_LARGO_Y_SEGURO';

      final response = await _dio.post(
        ApiConfig.getIdentidadUrl(ApiConfig.oauthToken),
        data: {
          'grant_type': 'password',
          'client_id': clientId,
          'client_secret': clientSecret,
          'username': email,
          'password': password, // Usar la contraseña real
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200) {
        print('✅ AUTH API: Usuario confirmado y puede autenticarse');
        return {
          'confirmed': true,
          'message': 'Usuario confirmado',
          'statusCode': response.statusCode,
        };
      } else {
        print('❌ AUTH API: Usuario no confirmado o credenciales incorrectas');
        return {
          'confirmed': false,
          'message': response.data['message'] ?? 'Usuario no confirmado',
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      print('❌ AUTH API: Error verificando confirmación - ${e.message}');

      if (e.response?.data != null) {
        final errorData = e.response!.data;
        String message = 'Error desconocido';

        if (errorData is Map<String, dynamic>) {
          message =
              errorData['message'] ??
              errorData['error'] ??
              'Error del servidor';
        } else if (errorData is String) {
          message = errorData;
        }

        return {
          'confirmed': false,
          'message': message,
          'statusCode': e.response?.statusCode ?? 500,
        };
      }

      return {
        'confirmed': false,
        'message': 'Error de conexión',
        'statusCode': 500,
      };
    } catch (e) {
      print('❌ AUTH API: Error inesperado verificando confirmación - $e');
      return {
        'confirmed': false,
        'message': 'Error inesperado: $e',
        'statusCode': 500,
      };
    }
  }

  /// Probar confirmación de email con token
  Future<void> testEmailConfirmation(String email, String token) async {
    try {
      print('🧪 AUTH API: === PRUEBA DE CONFIRMACIÓN DE EMAIL ===');
      print('📧 Email: $email');
      print('🔑 Token: $token');

      // PASO 1: Intentar confirmar email
      print('\n📧 PASO 1: Confirmando email...');
      try {
        final confirmDto = ConfirmEmailRequestDto(token: token);
        final confirmResponse = await confirmEmail(confirmDto);
        print('✅ Confirmación exitosa: ${confirmResponse.message}');
      } catch (e) {
        print('❌ Error en confirmación: $e');
      }

      // PASO 2: Verificar estado después de confirmación
      print('\n🔍 PASO 2: Verificando estado después de confirmación...');
      // Nota: Necesitamos la contraseña real para verificar
      print(
        '⚠️ Para verificar el estado, necesitas proporcionar la contraseña del usuario',
      );

      print('\n🧪 AUTH API: === FIN DE PRUEBA DE CONFIRMACIÓN ===');
    } catch (e) {
      print('❌ AUTH API: Error en prueba de confirmación - $e');
    }
  }

  /// Probar extracción de información del JWT
  Future<void> testJwtExtraction() async {
    try {
      print('🧪 AUTH API: === PRUEBA EXTRACCIÓN JWT ===');

      // Primero hacer login para obtener token
      const String email = 'amizadayguapo@gmail.com';
      const String password = 'Arturo2004!';

      print('🔐 PASO 1: Haciendo login para obtener token...');
      const String clientId = 'capbox_mobile_app_prod';
      const String clientSecret = 'UN_SECRETO_DE_PRODUCCION_MUY_LARGO_Y_SEGURO';

      final loginResponse = await _dio.post(
        ApiConfig.getIdentidadUrl(ApiConfig.oauthToken),
        data: {
          'grant_type': 'password',
          'client_id': clientId,
          'client_secret': clientSecret,
          'username': email,
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          validateStatus: (status) => status! < 600,
        ),
      );

      if (loginResponse.statusCode == 200) {
        final accessToken = loginResponse.data['access_token'];
        print('✅ Login exitoso, token obtenido');
        print('🔑 Token: ${accessToken.substring(0, 50)}...');

        // PASO 2: Probar extracción de información del JWT
        print('\n🔍 PASO 2: Probando extracción de información del JWT...');

        // Decodificar el token JWT (parte payload)
        final parts = accessToken.split('.');
        if (parts.length != 3) {
          print('❌ Token JWT inválido');
          return;
        }

        // Decodificar el payload (parte 2 del token)
        final payload = parts[1];
        // Agregar padding si es necesario
        final paddingLength = ((4 - payload.length % 4) % 4).toInt();
        final paddedPayload = payload + '=' * paddingLength;

        try {
          // Decodificar base64
          final decodedBytes = base64Url.decode(paddedPayload);
          final decodedString = utf8.decode(decodedBytes);
          final payloadData =
              json.decode(decodedString) as Map<String, dynamic>;

          print('✅ Extracción JWT exitosa');
          print('📊 Payload del token: $payloadData');

          // Mostrar información específica
          if (payloadData.containsKey('email')) {
            print('📧 Email: ${payloadData['email']}');
          }
          if (payloadData.containsKey('rol')) {
            print('🎭 Rol: ${payloadData['rol']}');
          }
          if (payloadData.containsKey('sub')) {
            print('🆔 ID: ${payloadData['sub']}');
          }
        } catch (e) {
          print('❌ Error decodificando JWT - $e');
        }
      } else {
        print('❌ Login fallido');
        print('📊 Status: ${loginResponse.statusCode}');
        print('📝 Respuesta: ${loginResponse.data}');
      }

      print('\n🧪 AUTH API: === FIN PRUEBA EXTRACCIÓN JWT ===');
    } catch (e) {
      print('❌ AUTH API: Error en prueba de extracción JWT - $e');
    }
  }

  /// Probar endpoint /usuarios/me
  Future<void> testUsersMeEndpoint() async {
    try {
      print('🧪 AUTH API: === PRUEBA ENDPOINT /usuarios/me ===');

      // Primero hacer login para obtener token
      const String email = 'amizadayguapo@gmail.com';
      const String password = 'Arturo2004!';

      print('🔐 PASO 1: Haciendo login para obtener token...');
      const String clientId = 'capbox_mobile_app_prod';
      const String clientSecret = 'UN_SECRETO_DE_PRODUCCION_MUY_LARGO_Y_SEGURO';

      final loginResponse = await _dio.post(
        ApiConfig.getIdentidadUrl(ApiConfig.oauthToken),
        data: {
          'grant_type': 'password',
          'client_id': clientId,
          'client_secret': clientSecret,
          'username': email,
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          validateStatus: (status) => status! < 600,
        ),
      );

      if (loginResponse.statusCode == 200) {
        final accessToken = loginResponse.data['access_token'];
        print('✅ Login exitoso, token obtenido');

        // PASO 2: Probar endpoint /usuarios/me
        print('\n👤 PASO 2: Probando endpoint /identity/v1/usuarios/me...');
        final userResponse = await _dio.get(
          '${ApiConfig.baseUrl}/identity/v1/usuarios/me', // CORREGIDO: Usar endpoint correcto
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            validateStatus: (status) => status! < 600,
          ),
        );

        if (userResponse.statusCode == 200) {
          print('✅ Endpoint /identity/v1/usuarios/me funciona correctamente');
          print('📊 Datos del usuario: ${userResponse.data}');
        } else {
          print('❌ Endpoint /identity/v1/usuarios/me falló');
          print('📊 Status: ${userResponse.statusCode}');
          print('📝 Respuesta: ${userResponse.data}');
        }
      } else {
        print('❌ Login fallido');
        print('📊 Status: ${loginResponse.statusCode}');
        print('📝 Respuesta: ${loginResponse.data}');
      }

      print('\n🧪 AUTH API: === FIN PRUEBA ENDPOINT /usuarios/me ===');
    } catch (e) {
      print('❌ AUTH API: Error en prueba de endpoint - $e');
    }
  }

  /// Probar caso específico de Arturo
  Future<void> testArturoCase() async {
    try {
      print('🧪 AUTH API: === PRUEBA CASO ARTURO ===');

      const String email = 'mr.arturolongo@gmail.com';
      const String password = 'Arturo2004!';
      const String confirmationCode = '198190'; // El código que usaste

      print('📧 Email: $email');
      print('🔑 Password: $password');
      print('🔢 Código de confirmación: $confirmationCode');

      // PASO 1: Verificar estado actual
      print('\n🔍 PASO 1: Estado actual...');
      final currentStatus = await checkUserConfirmationStatus(email, password);
      print('📊 Estado actual: $currentStatus');

      // PASO 2: Intentar confirmación con el código
      print('\n📧 PASO 2: Confirmando con código...');
      try {
        final confirmDto = ConfirmEmailRequestDto(token: confirmationCode);
        final confirmResponse = await confirmEmail(confirmDto);
        print('✅ Confirmación exitosa: ${confirmResponse.message}');
      } catch (e) {
        print('❌ Error en confirmación: $e');
      }

      // PASO 3: Verificar estado después de confirmación
      print('\n🔍 PASO 3: Estado después de confirmación...');
      final statusAfterConfirm = await checkUserConfirmationStatus(
        email,
        password,
      );
      print('📊 Estado después de confirmación: $statusAfterConfirm');

      // PASO 4: Intentar login
      print('\n🔐 PASO 4: Intentando login...');
      try {
        const String clientId = 'capbox_mobile_app_prod';
        const String clientSecret =
            'UN_SECRETO_DE_PRODUCCION_MUY_LARGO_Y_SEGURO';

        final loginResponse = await _dio.post(
          ApiConfig.getIdentidadUrl(ApiConfig.oauthToken),
          data: {
            'grant_type': 'password',
            'client_id': clientId,
            'client_secret': clientSecret,
            'username': email,
            'password': password,
          },
          options: Options(
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            validateStatus: (status) => status! < 600,
          ),
        );

        if (loginResponse.statusCode == 200) {
          print('✅ Login exitoso!');
          print(
            '🎫 Access Token: ${loginResponse.data['access_token']?.toString().substring(0, 20)}...',
          );
          print(
            '🔄 Refresh Token: ${loginResponse.data['refresh_token']?.toString().substring(0, 20)}...',
          );
        } else {
          print('❌ Login fallido');
          print('📊 Status: ${loginResponse.statusCode}');
          print('📝 Mensaje: ${loginResponse.data}');
        }
      } catch (e) {
        print('❌ Error en login: $e');
      }

      print('\n🧪 AUTH API: === FIN PRUEBA CASO ARTURO ===');
    } catch (e) {
      print('❌ AUTH API: Error en prueba de Arturo - $e');
    }
  }

  /// Probar flujo completo con confirmación de email
  Future<void> testCompleteFlowWithConfirmation(
    String email,
    String password,
    String token,
  ) async {
    try {
      print('🧪 AUTH API: === FLUJO COMPLETO CON CONFIRMACIÓN ===');
      print('📧 Email: $email');
      print('🔑 Password: $password');
      print('🎫 Token: $token');

      // PASO 1: Verificar estado inicial
      print('\n🔍 PASO 1: Estado inicial...');
      final initialStatus = await checkUserConfirmationStatus(email, password);
      print('📊 Estado inicial: $initialStatus');

      // PASO 2: Confirmar email
      print('\n📧 PASO 2: Confirmando email...');
      try {
        final confirmDto = ConfirmEmailRequestDto(token: token);
        final confirmResponse = await confirmEmail(confirmDto);
        print('✅ Confirmación exitosa: ${confirmResponse.message}');
      } catch (e) {
        print('❌ Error en confirmación: $e');
        return;
      }

      // PASO 3: Verificar estado después de confirmación
      print('\n🔍 PASO 3: Estado después de confirmación...');
      final statusAfterConfirm = await checkUserConfirmationStatus(
        email,
        password,
      );
      print('📊 Estado después de confirmación: $statusAfterConfirm');

      // PASO 4: Intentar login
      print('\n🔐 PASO 4: Intentando login...');
      try {
        const String clientId = 'capbox_mobile_app_prod';
        const String clientSecret =
            'UN_SECRETO_DE_PRODUCCION_MUY_LARGO_Y_SEGURO';

        final loginResponse = await _dio.post(
          ApiConfig.getIdentidadUrl(ApiConfig.oauthToken),
          data: {
            'grant_type': 'password',
            'client_id': clientId,
            'client_secret': clientSecret,
            'username': email,
            'password': password,
          },
          options: Options(
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            validateStatus: (status) => status! < 600,
          ),
        );

        if (loginResponse.statusCode == 200) {
          print('✅ Login exitoso después de confirmación!');
          print(
            '🎫 Access Token: ${loginResponse.data['access_token']?.toString().substring(0, 20)}...',
          );
          print(
            '🔄 Refresh Token: ${loginResponse.data['refresh_token']?.toString().substring(0, 20)}...',
          );
        } else {
          print('❌ Login fallido después de confirmación');
          print('📊 Status: ${loginResponse.statusCode}');
          print('📝 Mensaje: ${loginResponse.data}');
        }
      } catch (e) {
        print('❌ Error en login después de confirmación: $e');
      }

      print('\n🧪 AUTH API: === FIN DEL FLUJO COMPLETO ===');
    } catch (e) {
      print('❌ AUTH API: Error en flujo completo - $e');
    }
  }

  /// Confirmar email del usuario
  Future<ConfirmEmailResponseDto> confirmEmail(
    ConfirmEmailRequestDto dto,
  ) async {
    try {
      print('🚀 AUTH API: Confirmando email con token');

      final response = await _dio.post(
        ApiConfig.getIdentidadUrl(ApiConfig.confirmEmail),
        data: dto.toJson(),
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      print('✅ AUTH API: Email confirmado exitosamente');
      return ConfirmEmailResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ AUTH API: Error confirmando email - ${e.message}');
      print('📊 AUTH API: Status code: ${e.response?.statusCode}');

      if (e.response?.data != null) {
        print('🔍 AUTH API: Error detallado del backend:');
        print(e.response!.data);

        final errorData = e.response!.data;
        String errorMessage = 'Error desconocido';

        if (errorData is Map<String, dynamic>) {
          errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              'Error del servidor';
        } else if (errorData is String) {
          errorMessage = errorData;
        }

        throw Exception(errorMessage);
      }

      if (e.response?.statusCode == 401) {
        throw Exception('Token de confirmación inválido o expirado.');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      print('❌ AUTH API: Error inesperado - $e');
      throw Exception('Error inesperado: $e');
    }
  }
}
