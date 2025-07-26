import 'package:dio/dio.dart';
import 'aws_auth_service.dart';
import '../../features/admin/data/dtos/perfil_usuario_dto.dart';
import '../../features/admin/data/dtos/clave_gimnasio_dto.dart';

/// Servicio de API que usa tokens de AWS Cognito para autenticación
/// Se conecta al API Gateway: https://api.capbox.site/v1
class AWSApiService {
  final Dio _dio;
  final AWSAuthService _authService;

  // URL base del API Gateway
  // ✅ CLOUDFLARE ACTIVO: Volver a dominio personalizado
  static const String baseUrl = 'https://api.capbox.site';

  // 🚫 OBSOLETO: URL directa de AWS (ya no necesaria)
  // static const String baseUrl = 'https://trt6tqr8cc.execute-api.us-east-1.amazonaws.com';

  AWSApiService(this._authService) : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    _setupInterceptors();
  }

  /// Configurar interceptores para manejar autenticación automáticamente
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (
          RequestOptions options,
          RequestInterceptorHandler handler,
        ) async {
          await _handleRequest(options, handler);
        },
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          _handleResponse(response, handler);
        },
        onError: (DioException e, ErrorInterceptorHandler handler) {
          _handleError(e, handler);
        },
      ),
    );
  }

  /// Manejar peticiones salientes - agregar token de autenticación
  Future<void> _handleRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      print('🚀 API: ${options.method} ${options.uri}');
      print('📦 API: Data - ${options.data}');

      // Agregar headers básicos
      options.headers['Content-Type'] = 'application/json';
      options.headers['Accept'] = 'application/json';

      // Solo agregar token en endpoints que no son públicos
      if (!_isPublicEndpoint(options.path)) {
        final token = await _authService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          print('🔑 API: Token agregado a la petición');
        } else {
          print('⚠️ API: No hay token disponible para endpoint privado');
        }
      } else {
        print('🌐 API: Endpoint público - sin token requerido');
      }

      print('📋 API: Headers - ${options.headers}');
      handler.next(options);
    } catch (e) {
      print('❌ API: Error preparando petición - $e');
      handler.reject(
        DioException(
          requestOptions: options,
          message: 'Error preparando petición: $e',
        ),
      );
    }
  }

  /// Manejar respuestas
  void _handleResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ API: ${response.statusCode} ${response.requestOptions.uri}');
    print('📥 API: Response - ${response.data}');
    handler.next(response);
  }

  /// Manejar errores (MEJORADO para diagnóstico CORS)
  void _handleError(DioException e, ErrorInterceptorHandler handler) {
    print('❌ API: Error ${e.response?.statusCode} - ${e.message}');
    print('🔍 API: Error Type - ${e.type}');

    // 🌐 DIAGNÓSTICO ESPECÍFICO PARA ERRORES DE CONEXIÓN/CORS
    if (e.type == DioExceptionType.connectionError) {
      print('🚨 CORS/CONEXIÓN: Análisis detallado del error:');
      print('   📋 Request URL: ${e.requestOptions.uri}');
      print('   📋 Method: ${e.requestOptions.method}');
      print('   📋 Headers enviados: ${e.requestOptions.headers}');
      print('   🔍 Error completo: ${e.message}');
      print('   ⚠️  Este error típicamente indica:');
      print('      • Problema de CORS (preflight OPTIONS falló)');
      print('      • Servidor no disponible');
      print('      • Bloqueo de firewall/proxy');
      print('   💡 Revisar consola del navegador para más detalles CORS');
    }

    // 📊 DETALLES DE RESPUESTA (si existe)
    if (e.response != null) {
      print('📊 Response Status: ${e.response?.statusCode}');
      print('📊 Response Headers: ${e.response?.headers}');
      print('📥 API: Error Data - ${e.response?.data}');
    }

    // Si es 401, el token probablemente expiró
    if (e.response?.statusCode == 401) {
      print('🔐 API: Token expirado o inválido - usuario debe reautenticarse');
    }

    handler.next(e);
  }

  /// Verificar si un endpoint es público (no requiere autenticación)
  bool _isPublicEndpoint(String path) {
    final publicEndpoints = [
      '/auth/register',
      '/auth/login',
      '/health',
      '/gyms/validate-key', // Validar clave del gimnasio es público
    ];

    return publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  /// Vincular cuenta con gimnasio (ESPECIFICACIÓN v1.4.5)
  Future<Response> linkAccountToGym(String claveGym) async {
    try {
      print('🔗 API: Vinculando cuenta con gimnasio');
      print('🌐 API: Endpoint: POST /v1/gyms/link');
      print('🏋️ API: Clave: $claveGym');

      final response = await _dio.post(
        '/v1/gyms/link',
        data: {'claveGym': claveGym},
      );

      print('✅ API: Cuenta vinculada exitosamente');
      print('📊 API: Respuesta: ${response.data}');
      return response;
    } catch (e) {
      print('❌ API: Error vinculando cuenta - $e');
      rethrow;
    }
  }

  /// Obtener información del usuario actual - REQUERIDO POR BACKEND
  Future<Response> getUserMe() async {
    try {
      print('👤 API: Obteniendo información del usuario actual');
      print('🌐 API: Endpoint: GET /v1/users/me');

      final response = await _dio.get('/v1/users/me');

      print('✅ API: Información del usuario obtenida');
      print('📊 API: Respuesta: ${response.data}');
      return response;
    } catch (e) {
      print('❌ API: Error obteniendo información del usuario - $e');
      rethrow;
    }
  }

  /// Obtener la clave del gimnasio del entrenador actual - ENDPOINT OFICIAL
  Future<Response> getMyGymKey() async {
    try {
      print('🗝️ API: Obteniendo clave del gimnasio');
      print('🌐 API: Endpoint: GET /v1/profile/gym/key');

      final response = await _dio.get('/v1/profile/gym/key');

      print('✅ API: Clave del gimnasio obtenida');
      print('📊 API: Respuesta: ${response.data}');
      return response;
    } catch (e) {
      print('❌ API: Error obteniendo clave del gimnasio - $e');
      rethrow;
    }
  }

  /// Obtener la clave del gimnasio (ESPECIFICACIÓN v1.4.5)
  Future<Response> getAdminGymKey() async {
    try {
      print('🗝️ API: Obteniendo clave del gimnasio');
      print('🌐 API: Endpoint: GET /v1/profile/gym/key');
      print('👑 API: Roles permitidos: Admin, Entrenador');

      final response = await _dio.get('/v1/profile/gym/key');

      print('✅ API: Clave del gimnasio obtenida');
      print('📊 API: Respuesta: ${response.data}');
      return response;
    } catch (e) {
      print('❌ API: Error obteniendo clave del gimnasio - $e');
      rethrow;
    }
  }

  /// Actualizar la clave del gimnasio del admin (ESPECIFICACIÓN FINAL v1.4.5)
  Future<Response> updateAdminGymKey(String newKey) async {
    try {
      print('🗝️ API: Actualizando clave del gimnasio del admin: $newKey');
      print(
        '🌐 API: Endpoint: PATCH /v1/profile/gym/key (especificación final)',
      );

      final response = await _dio.patch(
        '/v1/profile/gym/key',
        data: {'nuevaClave': newKey}, // ← CAMBIO CLAVE: nuevaClave
      );

      print('✅ API: Clave del gimnasio del admin actualizada');
      return response;
    } catch (e) {
      print('❌ API: Error actualizando clave del gimnasio del admin - $e');
      rethrow;
    }
  }

  // ==============================
  // MÉTODOS DE AUTENTICACIÓN
  // ==============================

  /// POST /auth/register - Registrar usuario (público)
  Future<Response> registerUser({
    required String email,
    required String password,
    required String nombre,
    required String rol,
    required String claveGym,
  }) async {
    try {
      print('🚀 API: Registrando usuario en backend');

      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'nombre': nombre,
          'rol': rol,
          'claveGym': claveGym,
        },
      );

      print('✅ API: Usuario registrado en backend');
      return response;
    } catch (e) {
      print('❌ API: Error registrando usuario - $e');
      rethrow;
    }
  }

  /// GET /users/me - Obtener perfil del usuario actual
  Future<Response> getUserProfile() async {
    try {
      print('🚀 API: Obteniendo perfil de usuario');

      final response = await _dio.get('/v1/users/me');

      print('✅ API: Perfil obtenido');
      return response;
    } catch (e) {
      print('❌ API: Error obteniendo perfil - $e');
      rethrow;
    }
  }

  // ==============================
  // MÉTODOS DE PLANIFICACIÓN
  // ==============================

  /// GET /planning/routines - Obtener rutinas
  Future<Response> getRoutines({String? nivel}) async {
    try {
      print(
        '🚀 API: Obteniendo rutinas ${nivel != null ? "para nivel $nivel" : ""}',
      );

      final queryParams =
          nivel != null ? {'nivel': nivel} : <String, dynamic>{};
      final response = await _dio.get(
        '/planning/routines',
        queryParameters: queryParams,
      );

      print('✅ API: Rutinas obtenidas');
      return response;
    } catch (e) {
      print('❌ API: Error obteniendo rutinas - $e');
      rethrow;
    }
  }

  /// GET /planning/routines/{id} - Obtener detalle de rutina
  Future<Response> getRoutineDetail(int routineId) async {
    try {
      print('🚀 API: Obteniendo detalle de rutina $routineId');

      final response = await _dio.get('/v1/planning/routines/$routineId');

      print('✅ API: Detalle de rutina obtenido');
      return response;
    } catch (e) {
      print('❌ API: Error obteniendo detalle de rutina - $e');
      rethrow;
    }
  }

  /// GET /planning/assignments/me - Obtener mis asignaciones
  Future<Response> getMyAssignments() async {
    try {
      print('🚀 API: Obteniendo mis asignaciones');

      final response = await _dio.get('/v1/planning/assignments/me');

      print('✅ API: Asignaciones obtenidas');
      return response;
    } catch (e) {
      print('❌ API: Error obteniendo asignaciones - $e');
      rethrow;
    }
  }

  /// POST /planning/assignments - Asignar rutina a atleta
  Future<Response> assignRoutine({
    required int atletaId,
    required int rutinaId,
    required String objetivos,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      print('🚀 API: Asignando rutina $rutinaId a atleta $atletaId');

      final response = await _dio.post(
        '/planning/assignments',
        data: {
          'atletaId': atletaId,
          'rutinaId': rutinaId,
          'objetivos': objetivos,
          'fechaInicio': fechaInicio?.toIso8601String(),
          'fechaFin': fechaFin?.toIso8601String(),
        },
      );

      print('✅ API: Rutina asignada');
      return response;
    } catch (e) {
      print('❌ API: Error asignando rutina - $e');
      rethrow;
    }
  }

  /// PUT /planning/assignments/{id}/status - Actualizar estado de asignación
  Future<Response> updateAssignmentStatus(
    int assignmentId,
    String status,
  ) async {
    try {
      print(
        '🚀 API: Actualizando estado de asignación $assignmentId a $status',
      );

      final response = await _dio.put(
        '/planning/assignments/$assignmentId/status',
        data: {'estado': status},
      );

      print('✅ API: Estado actualizado');
      return response;
    } catch (e) {
      print('❌ API: Error actualizando estado - $e');
      rethrow;
    }
  }

  // ==============================
  // MÉTODOS DE GIMNASIO/ADMIN
  // ==============================

  /// GET /gyms/members - Obtener miembros del gimnasio
  Future<Response> getGymMembers() async {
    try {
      print('🚀 API: Obteniendo miembros del gimnasio');

      final response = await _dio.get('/v1/gyms/members');

      print('✅ API: Miembros obtenidos');
      return response;
    } catch (e) {
      print('❌ API: Error obteniendo miembros - $e');
      rethrow;
    }
  }

  /// GET /requests/pending - Obtener solicitudes pendientes (ENDPOINT ACTUALIZADO)
  Future<Response> getPendingRequests() async {
    try {
      print('🚀 API: Obteniendo solicitudes pendientes');

      final response = await _dio.get('/v1/requests/pending');

      print('✅ API: Solicitudes obtenidas');
      return response;
    } catch (e) {
      print('❌ API: Error obteniendo solicitudes - $e');
      rethrow;
    }
  }

  /// POST /athletes/{id}/approve - Aprobar atleta con datos completos (ENDPOINT ACTUALIZADO)
  Future<Response> approveAthlete({
    required int athleteId,
    required Map<String, dynamic> physicalData,
    required Map<String, dynamic> tutorData,
  }) async {
    try {
      print('🚀 API: Aprobando atleta $athleteId con datos completos');

      final response = await _dio.post(
        '/athletes/$athleteId/approve',
        data: {'datosFisicos': physicalData, 'datosTutor': tutorData},
      );

      print('✅ API: Atleta aprobado con datos completos');
      return response;
    } catch (e) {
      print('❌ API: Error aprobando atleta - $e');
      rethrow;
    }
  }

  // ==============================
  // MÉTODO GENÉRICO
  // ==============================

  /// Realizar petición HTTP genérica
  Future<Response> request(
    String method,
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      print('🚀 API: $method $path');

      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );

      print('✅ API: $method $path completado');
      return response;
    } catch (e) {
      print('❌ API: Error en $method $path - $e');
      rethrow;
    }
  }
}
