import 'package:flutter/foundation.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/aws_api_service.dart';
import '../../../../core/services/user_display_service.dart';
import '../../domain/entities/user.dart';

/// Estados del login con OAuth2
enum AWSLoginState { initial, loading, authenticated, unauthenticated, error }

/// Cubit para manejar el login de usuarios con OAuth2
class AWSLoginCubit extends ChangeNotifier {
  final AuthService _authService;
  final AWSApiService _apiService;

  AWSLoginState _state = AWSLoginState.initial;
  String? _errorMessage;
  User? _currentUser;

  AWSLoginCubit(this._authService, this._apiService) {
    _checkInitialAuthState();
  }

  // Getters
  AWSLoginState get state => _state;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isLoading => _state == AWSLoginState.loading;
  bool get isAuthenticated =>
      _state == AWSLoginState.authenticated && _currentUser != null;

  /// Verificar estado inicial de autenticación
  Future<void> _checkInitialAuthState() async {
    try {
      print('🚀 LOGIN: Verificando estado inicial de autenticación');

      final isSignedIn = await _authService.isSignedIn();
      if (isSignedIn) {
        print('✅ LOGIN: Usuario ya autenticado');
        await _loadUserProfile();
      } else {
        print('ℹ️ LOGIN: Usuario no autenticado');
        _setState(AWSLoginState.unauthenticated);
      }
    } catch (e) {
      print('❌ LOGIN: Error verificando estado inicial - $e');
      _setState(AWSLoginState.unauthenticated);
    }
  }

  /// Iniciar sesión con email y contraseña
  Future<void> login(String email, String password) async {
    try {
      print('🚀 LOGIN: Iniciando sesión');
      print('📧 Email: $email');

      _setState(AWSLoginState.loading);
      _clearError();

      // PASO 1: Autenticar con Cognito
      final result = await _authService.signIn(
        email: email,
        password: password,
      );

      if (result == null) {
        throw Exception('Error en autenticación: Credenciales inválidas');
      }

      print('✅ LOGIN: Autenticación exitosa en Cognito');

      // PASO 2: Cargar perfil del usuario
      await _loadUserProfile();
    } catch (e) {
      print('❌ LOGIN: Error inesperado - $e');
      _setError('Error inesperado durante el login: $e');
      _setState(AWSLoginState.error);
    }
  }

  /// Cargar perfil del usuario desde Cognito y/o Backend
  Future<void> _loadUserProfile() async {
    try {
      print('🚀 LOGIN: Cargando perfil de usuario');

      // Obtener información básica de Cognito
      final cognitoUser = await _authService.getCurrentUser();
      final attributes = await _authService.getUserAttributes();

      if (cognitoUser == null) {
        throw Exception('No se pudo obtener información del usuario');
      }

      // Extraer atributos
      final email = cognitoUser['email'] ?? cognitoUser['username'] ?? '';
      String? name;
      String? role;
      String? gymKey;

      for (final attr in attributes) {
        final key = attr['userAttributeKey']['key'];
        final value = attr['value'];

        switch (key) {
          case 'name':
            name = value;
            break;
          case 'custom:rol':
            role = value;
            break;
          case 'custom:claveGym':
            gymKey = value;
            break;
        }
      }

      // Obtener token de acceso
      final accessToken = await _authService.getAccessToken();

      // Crear objeto User
      _currentUser = User(
        id: cognitoUser['username'] ?? cognitoUser['sub'] ?? '',
        name: name ?? 'Usuario',
        email: email,
        role: _parseRole(role),
        createdAt: DateTime.now(), // Se actualizará con datos reales
        token: accessToken ?? '', // Token JWT de Cognito
      );

      print('✅ LOGIN: Perfil de usuario cargado');
      print('👤 Usuario: ${_currentUser!.name}');
      print('📧 Email: ${_currentUser!.email}');
      print('🎭 Rol: ${_currentUser!.role}');

      _setState(AWSLoginState.authenticated);

      // Opcional: Sincronizar con backend
      // await _syncWithBackend();
    } catch (e) {
      print('❌ LOGIN: Error cargando perfil - $e');
      _setError('Error cargando perfil de usuario: $e');
      _setState(AWSLoginState.error);
    }
  }

  /// Sincronizar datos con el backend (opcional)
  Future<void> _syncWithBackend() async {
    try {
      print('🚀 LOGIN: Sincronizando con backend');

      final response = await _apiService.getUserProfile();

      print('✅ LOGIN: Datos sincronizados con backend');
      print('📥 Respuesta: ${response.data}');

      // Actualizar datos del usuario con información del backend
      // _updateUserFromBackend(response.data);
    } catch (e) {
      print('⚠️ LOGIN: Error sincronizando con backend - $e');
      // No es crítico, el usuario puede usar la app solo con datos de Cognito
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    try {
      print('🚀 LOGIN: Cerrando sesión');

      await _authService.signOut();

      _currentUser = null;
      _setState(AWSLoginState.unauthenticated);
      _clearError();

      // 🗑️ LIMPIAR CACHÉ DE USUARIO AL HACER LOGOUT
      UserDisplayService.clearGlobalCache();

      print('✅ LOGIN: Sesión cerrada exitosamente');
    } catch (e) {
      print('❌ LOGIN: Error cerrando sesión - $e');
      // Forzar logout local
      _currentUser = null;
      _setState(AWSLoginState.unauthenticated);

      // 🗑️ LIMPIAR CACHÉ TAMBIÉN EN CASO DE ERROR
      UserDisplayService.clearGlobalCache();
    }
  }

  /// Obtener ruta de home según el rol del usuario
  String getHomeRoute() {
    if (_currentUser == null) return '/login';

    switch (_currentUser!.role) {
      case UserRole.athlete:
        return '/boxer-home';
      case UserRole.coach:
        return '/coach-home';
      case UserRole.admin:
        return '/admin-home';
    }
  }

  /// Verificar si el usuario necesita vinculación usando GET /users/me
  Future<bool> needsGymKeyActivation() async {
    try {
      if (_currentUser == null) return false;

      // 🚨 ADMINS NUNCA NECESITAN CLAVE - PRIORIDAD ABSOLUTA
      if (_currentUser!.role == UserRole.admin) {
        print('👑 LOGIN: Usuario es ADMIN - NO necesita vinculación');
        return false;
      }

      print(
        '🔍 LOGIN: Verificando vinculación con GET /users/me para ${_currentUser!.role}',
      );

      // Llamar a GET /users/me para verificar estado según backend
      final response = await _apiService.getUserMe();
      final userData = response.data;

      // Si gimnasio es null, necesita vinculación
      final gimnasio = userData['gimnasio'];
      final needsLink = gimnasio == null;

      print('🏋️ LOGIN: Estado gimnasio: ${gimnasio ?? "null"}');
      print('📊 LOGIN: Necesita vinculación: $needsLink');

      return needsLink;
    } catch (e) {
      print('❌ LOGIN: Error verificando vinculación - $e');

      // 🚨 SI HAY ERROR Y ES ADMIN, NO PEDIR CLAVE
      if (_currentUser?.role == UserRole.admin) {
        print('👑 LOGIN: Error pero es ADMIN - NO necesita vinculación');
        return false;
      }

      // Para boxers/coaches, en caso de error asumir que necesita vinculación
      print(
        '⚠️ LOGIN: Error para ${_currentUser?.role} - asumir que necesita vinculación',
      );
      return true;
    }
  }

  /// Obtener ruta considerando el estado de activación
  Future<String> getRouteWithActivationCheck() async {
    if (_currentUser == null) return '/login';

    // Verificar si necesita activación
    final needsActivation = await needsGymKeyActivation();

    if (needsActivation) {
      return '/gym-key-required';
    }

    // Si no necesita activación, usar ruta normal
    return getHomeRoute();
  }

  /// Verificar estado de autenticación actual
  Future<void> checkAuthStatus() async {
    try {
      final isSignedIn = await _authService.isSignedIn();
      if (isSignedIn && _currentUser == null) {
        await _loadUserProfile();
      } else if (!isSignedIn && _currentUser != null) {
        _currentUser = null;
        _setState(AWSLoginState.unauthenticated);
      }
    } catch (e) {
      print('❌ LOGIN: Error verificando estado auth - $e');
    }
  }

  /// Refrescar token de acceso (manejado automáticamente por Amplify)
  Future<String?> getAccessToken() async {
    try {
      return await _authService.getAccessToken();
    } catch (e) {
      print('❌ LOGIN: Error obteniendo token - $e');
      return null;
    }
  }

  /// Manejar errores específicos de login
  void _handleLoginError(Exception e) {
    String userMessage;
    final message = e.toString().toLowerCase();

    if (message.contains('incorrect username or password')) {
      userMessage = 'Email o contraseña incorrectos.';
    } else if (message.contains('user is not confirmed')) {
      userMessage =
          'Tu cuenta no está confirmada. Revisa tu email para el código de confirmación.';
    } else if (message.contains('user does not exist')) {
      userMessage = 'No existe una cuenta con este email.';
    } else if (message.contains('password attempts exceeded')) {
      userMessage = 'Demasiados intentos fallidos. Intenta de nuevo más tarde.';
    } else {
      userMessage = 'Error de autenticación: ${e.toString()}';
    }

    _setError(userMessage);
    _setState(AWSLoginState.error);
  }

  /// Parsear rol desde string
  UserRole _parseRole(String? roleString) {
    switch (roleString?.toLowerCase()) {
      case 'atleta':
        return UserRole.athlete;
      case 'entrenador':
        return UserRole.coach;
      case 'administrador':
        return UserRole.admin;
      default:
        return UserRole.athlete; // Default
    }
  }

  /// Helpers privados
  void _setState(AWSLoginState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
