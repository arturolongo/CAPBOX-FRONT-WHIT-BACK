import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

class ApiInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // No modificar base URL si ya tiene una (se maneja en los API clients)
    if (!options.path.startsWith('http') && options.baseUrl.isEmpty) {
      // Determinar qué microservicio usar basado en el path
      if (_isIdentidadEndpoint(options.path)) {
        options.baseUrl = ApiConfig.identidadBaseUrl;
      } else if (_isPlanificacionEndpoint(options.path)) {
        options.baseUrl = ApiConfig.planificacionBaseUrl;
      }
    }

    // Add auth token if available (excepto para login y register)
    if (!_isPublicEndpoint(options.path)) {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    // Add default headers
    options.headers.addAll(ApiConfig.defaultHeaders);

    print('🚀 REQUEST: ${options.method} ${options.uri}');
    print('📦 DATA: ${options.data}');
    print('🔑 HEADERS: ${options.headers}');

    handler.next(options);
  }

  bool _isIdentidadEndpoint(String path) {
    return path.contains('/v1/auth/') ||
        path.contains('/v1/oauth/') ||
        path.contains('/v1/users/') ||
        path.contains('/v1/requests/') ||
        path.contains('/v1/athletes/') ||
        path.contains('/v1/gyms/');
  }

  bool _isPlanificacionEndpoint(String path) {
    return path.contains('/v1/planning/');
  }

  bool _isPublicEndpoint(String path) {
    return path.contains('/v1/auth/register') ||
        path.contains('/v1/oauth/token');
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    print('📥 DATA: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('❌ ERROR: ${err.response?.statusCode} ${err.requestOptions.uri}');
    print('💥 MESSAGE: ${err.message}');
    print('📄 RESPONSE: ${err.response?.data}');

    // Handle 401 Unauthorized - Token expired
    if (err.response?.statusCode == 401) {
      await _handleTokenRefresh(err, handler);
      return;
    }

    // Handle other HTTP errors
    final errorMessage = _getErrorMessage(err);
    final customError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage,
    );

    handler.next(customError);
  }

  Future<void> _handleTokenRefresh(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      // Attempt to refresh token
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        // No refresh token available, user needs to login again
        await _secureStorage.deleteAll();
        handler.next(err);
        return;
      }

      // Create a new Dio instance to avoid interceptor recursion
      final dio = Dio();
      final response = await dio.post(
        ApiConfig.getIdentidadUrl(ApiConfig.oauthToken),
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': ApiConfig.oauthClientId,
          'client_secret': ApiConfig.oauthClientSecret,
        },
      );

      if (response.statusCode == 200) {
        final newToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];

        await _secureStorage.write(key: 'auth_token', value: newToken);
        await _secureStorage.write(
          key: 'refresh_token',
          value: newRefreshToken,
        );

        // Retry the original request with new token
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newToken';

        final retryDio = Dio();
        final retryResponse = await retryDio.fetch(options);
        handler.resolve(retryResponse);
      } else {
        await _secureStorage.deleteAll();
        handler.next(err);
      }
    } catch (e) {
      await _secureStorage.deleteAll();
      handler.next(err);
    }
  }

  String _getErrorMessage(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tiempo de conexión agotado';
      case DioExceptionType.sendTimeout:
        return 'Tiempo de envío agotado';
      case DioExceptionType.receiveTimeout:
        return 'Tiempo de recepción agotado';
      case DioExceptionType.connectionError:
        return 'Error de conexión';
      case DioExceptionType.cancel:
        return 'Petición cancelada';
      case DioExceptionType.unknown:
        return 'Error desconocido';
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        switch (statusCode) {
          case 400:
            return 'Petición incorrecta';
          case 401:
            return 'No autorizado';
          case 403:
            return 'Acceso prohibido';
          case 404:
            return 'Recurso no encontrado';
          case 500:
            return 'Error interno del servidor';
          case 502:
            return 'Bad Gateway';
          case 503:
            return 'Servicio no disponible';
          default:
            return 'Error del servidor ($statusCode)';
        }
      case DioExceptionType.badCertificate:
        return 'Certificado inválido';
    }
  }
}
