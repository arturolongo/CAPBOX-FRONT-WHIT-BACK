import 'package:dio/dio.dart';
import 'auth_service.dart';
import 'auth_interceptor.dart';
import '../../features/admin/data/dtos/perfil_usuario_dto.dart';
import '../../features/admin/data/dtos/clave_gimnasio_dto.dart';

/// Servicio de API que usa tokens OAuth2 para autenticación
/// Se conecta al API Gateway: https://api.capbox.site/v1
class AWSApiService {
  final Dio _dio;
  final AuthService _authService;

  // URL base del API Gateway
  // ✅ DOMINIO PERSONALIZADO: Sin /v1 para evitar duplicación
  static const String baseUrl = 'https://api.capbox.site';

  AWSApiService(this._authService) : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    _setupInterceptors();
  }

  /// Configurar interceptores para manejar autenticación automáticamente
  void _setupInterceptors() {
    _dio.interceptors.add(AuthInterceptor());
  }

  /// Realizar petición GET genérica
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      print('🚀 API: GET $path');
      final response = await _dio.get(path, queryParameters: queryParameters);
      print('✅ API: GET $path completado');
      return response;
    } catch (e) {
      print('❌ API: Error en GET $path - $e');
      rethrow;
    }
  }

  /// Realizar petición POST genérica
  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      print('🚀 API: POST $path');
      final response = await _dio.post(path, data: data);
      print('✅ API: POST $path completado');
      return response;
    } catch (e) {
      print('❌ API: Error en POST $path - $e');
      rethrow;
    }
  }

  /// Vincular cuenta con gimnasio
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

  /// Obtener información del usuario actual
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

  /// Obtener perfil del usuario
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

  /// Registrar usuario
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

  /// Obtener clave del gimnasio del administrador
  Future<Response> getAdminGymKey() async {
    try {
      print('🔑 API: Obteniendo clave del gimnasio del administrador');
      print('🌐 API: Endpoint: GET /v1/users/me/gym/key');

      final response = await _dio.get('/v1/users/me/gym/key');

      print('✅ API: Clave del gimnasio obtenida');
      print('📊 API: Respuesta: ${response.data}');
      return response;
    } catch (e) {
      print('❌ API: Error obteniendo clave del gimnasio - $e');
      rethrow;
    }
  }

  /// Actualizar clave del gimnasio del administrador
  Future<Response> updateAdminGymKey(String newKey) async {
    try {
      print('🔑 API: Actualizando clave del gimnasio del administrador');
      print('🌐 API: Endpoint: PATCH /v1/users/me/gym/key');
      print('🔑 API: Nueva clave: $newKey');

      final response = await _dio.patch(
        '/v1/users/me/gym/key',
        data: {'claveGym': newKey},
      );

      print('✅ API: Clave del gimnasio actualizada');
      print('📊 API: Respuesta: ${response.data}');
      return response;
    } catch (e) {
      print('❌ API: Error actualizando clave del gimnasio - $e');
      rethrow;
    }
  }

  /// Obtener clave del gimnasio del entrenador
  Future<Response> getMyGymKey() async {
    try {
      print('🔑 API: Obteniendo clave del gimnasio del entrenador');
      print('🌐 API: Endpoint: GET /v1/users/me/gym/key');

      final response = await _dio.get('/v1/users/me/gym/key');

      print('✅ API: Clave del gimnasio obtenida');
      print('📊 API: Respuesta: ${response.data}');
      return response;
    } catch (e) {
      print('❌ API: Error obteniendo clave del gimnasio - $e');
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

      // 🚫 TEMPORAL: Agregar ID de entrenador
      final data = {'coachId': _coachUserId};

      final response = await _dio.post('/v1/requests/pending', data: data);

      print('✅ API: Solicitudes obtenidas');
      return response;
    } catch (e) {
      print('❌ API: Error obteniendo solicitudes - $e');
      rethrow;
    }
  }

  /// POST /performance/attendance - Registrar asistencia (Entrenador)
  Future<Response> registerAttendance({
    required DateTime fecha,
    required List<String> atletasPresentes,
  }) async {
    try {
      print('🚀 API: Registrando asistencia para fecha: $fecha');

      final data = {
        'fecha': fecha.toIso8601String(),
        'atletasPresentes': atletasPresentes,
      };

      // 🚫 TEMPORAL: Agregar ID de entrenador
      final dataWithUserId = _addCoachUserId(data);

      final response = await _dio.post(
        '/v1/performance/attendance',
        data: dataWithUserId,
      );

      print('✅ API: Asistencia registrada');
      return response;
    } catch (e) {
      print('❌ API: Error registrando asistencia - $e');
      rethrow;
    }
  }

  /// POST /performance/sessions - Registrar sesión de entrenamiento (Atleta)
  Future<Response> registerTrainingSession({
    required String tipoSesion,
    required int duracionMinutos,
    required Map<String, dynamic> ejercicios,
  }) async {
    try {
      print('🚀 API: Registrando sesión de entrenamiento');

      final data = {
        'tipoSesion': tipoSesion,
        'duracionMinutos': duracionMinutos,
        'ejercicios': ejercicios,
      };

      // 🚫 TEMPORAL: Agregar ID de atleta
      final dataWithUserId = _addAthleteUserId(data);

      final response = await _dio.post(
        '/v1/performance/sessions',
        data: dataWithUserId,
      );

      print('✅ API: Sesión de entrenamiento registrada');
      return response;
    } catch (e) {
      print('❌ API: Error registrando sesión de entrenamiento - $e');
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

  /// 🚫 TEMPORAL: IDs de usuario de prueba para diferentes roles
  static const String _adminUserId = '00000000-0000-0000-0000-000000000001';
  static const String _coachUserId = '00000000-0000-0000-0000-000000000002';
  static const String _athleteUserId = '00000000-0000-0000-0000-000000000003';

  /// Agregar ID de usuario de prueba según el contexto
  Map<String, dynamic> _addTestUserId(
    Map<String, dynamic> data, {
    String? userId,
  }) {
    final newData = Map<String, dynamic>.from(data);
    newData['userId'] = userId ?? _athleteUserId; // Por defecto atleta
    return newData;
  }

  /// Agregar ID de administrador
  Map<String, dynamic> _addAdminUserId(Map<String, dynamic> data) {
    return _addTestUserId(data, userId: _adminUserId);
  }

  /// Agregar ID de entrenador
  Map<String, dynamic> _addCoachUserId(Map<String, dynamic> data) {
    return _addTestUserId(data, userId: _coachUserId);
  }

  /// Agregar ID de atleta
  Map<String, dynamic> _addAthleteUserId(Map<String, dynamic> data) {
    return _addTestUserId(data, userId: _athleteUserId);
  }

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
