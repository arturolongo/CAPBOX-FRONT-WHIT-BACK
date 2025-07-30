import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  AuthInterceptor() : _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      print('🔑 AUTH INTERCEPTOR: Procesando petición a ${options.uri}');

      // Verificar si es un endpoint público
      if (_isPublicEndpoint(options.path)) {
        print('🌐 AUTH INTERCEPTOR: Endpoint público - sin token requerido');
        return super.onRequest(options, handler);
      }

      // Leer el token del almacenamiento seguro
      final accessToken = await _secureStorage.read(key: 'access_token');

      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        print('🔑 AUTH INTERCEPTOR: Token agregado a la petición');
        print('🔍 AUTH INTERCEPTOR: Token: ${accessToken.substring(0, 50)}...');
        print('📋 AUTH INTERCEPTOR: Headers: ${options.headers}');
      } else {
        print(
          '⚠️ AUTH INTERCEPTOR: No hay token disponible para endpoint privado',
        );
        print(
          '❌ AUTH INTERCEPTOR: Endpoint requiere autenticación pero no hay token',
        );
        // Podrías decidir si rechazar la petición o continuar sin token
        // Para pruebas, continuamos sin token
      }

      return super.onRequest(options, handler);
    } catch (e) {
      print('❌ AUTH INTERCEPTOR: Error procesando petición - $e');
      return super.onRequest(options, handler);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ AUTH INTERCEPTOR: Respuesta exitosa ${response.statusCode}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ AUTH INTERCEPTOR: Error ${err.response?.statusCode}');

    // Si es 401, el token probablemente expiró
    if (err.response?.statusCode == 401) {
      print(
        '🔐 AUTH INTERCEPTOR: Token expirado o inválido - usuario debe reautenticarse',
      );
      // Aquí podrías implementar lógica para refrescar el token automáticamente
    }

    super.onError(err, handler);
  }

  /// Verificar si un endpoint es público (no requiere autenticación)
  bool _isPublicEndpoint(String path) {
    final publicEndpoints = [
      '/auth/register',
      '/oauth/token',
      '/auth/forgot-password',
      '/auth/reset-password',
      '/health',
    ];

    return publicEndpoints.any((endpoint) => path.contains(endpoint));
  }
}
