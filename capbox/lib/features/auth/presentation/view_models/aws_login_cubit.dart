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
        // El error específico ya fue lanzado por AuthService
        // No necesitamos lanzar una excepción genérica aquí
        return;
      }

      print('✅ LOGIN: Autenticación exitosa en Cognito');

      // PASO 2: Cargar perfil del usuario
      await _loadUserProfile();
    } catch (e) {
      print('❌ LOGIN: Error inesperado - $e');

      // Mostrar el mensaje específico del error
      String errorMessage = e.toString();
      if (errorMessage.contains('confirma tu correo electrónico')) {
        _setError(
          'Por favor, confirma tu correo electrónico antes de iniciar sesión. Revisa tu bandeja de entrada.',
        );
      } else if (errorMessage.contains('Credenciales incorrectas')) {
        _setError('Credenciales incorrectas. Verifica tu email y contraseña.');
      } else {
        _setError('Error inesperado durante el login: $e');
      }

      _setState(AWSLoginState.error);
    }
  }

  /// Cargar perfil del usuario desde el Backend
  Future<void> _loadUserProfile() async {
    try {
      print('🚀 LOGIN: Cargando perfil de usuario desde BACKEND');

      // Obtener perfil desde el backend usando el token de Cognito
      final userProfile = await _apiService.getUserProfile();

      if (userProfile.statusCode == 200) {
        final userData = userProfile.data as Map<String, dynamic>;
        print('✅ LOGIN: Perfil cargado desde backend exitosamente');
        print('📊 LOGIN: Datos del perfil del backend:');
        print('  - ID: ${userData['id']}');
        print('  - Email: ${userData['email']}');
        print('  - Nombre: ${userData['nombre']}');
        print('  - Rol: ${userData['rol']}');
        print('  - Gimnasio: ${userData['gimnasio']}');

        // Crear objeto User con datos del backend
        _currentUser = User(
          id: userData['id'],
          name: userData['nombre'],
          email: userData['email'],
          role: _parseRole(userData['rol']),
          createdAt: DateTime.now(),
          token: await _authService.getAccessToken() ?? '',
        );

        print('✅ LOGIN: Usuario creado con datos del backend');
        print('👤 Usuario: ${_currentUser!.name}');
        print('📧 Email: ${_currentUser!.email}');
        print('🎭 Rol: ${_currentUser!.role}');
        print('🔍 LOGIN: Ruta de home calculada: ${getHomeRoute()}');
        print('🔍 LOGIN: Rol parseado: ${_currentUser!.role}');
        print('🔍 LOGIN: ¿Es coach? ${_currentUser!.role == UserRole.coach}');
        print(
          '🔍 LOGIN: ¿Es athlete? ${_currentUser!.role == UserRole.athlete}',
        );
        print('🔍 LOGIN: ¿Es admin? ${_currentUser!.role == UserRole.admin}');

        // Auto-fix para coaches pendientes
        await autoFixCoachStatus();

        _setState(AWSLoginState.authenticated);

        // 🚀 NAVEGACIÓN AUTOMÁTICA DESPUÉS DEL LOGIN EXITOSO
        print('🚀 LOGIN: Login exitoso, navegando automáticamente...');
        final homeRoute = getHomeRoute();
        print('🏠 LOGIN: Navegando a: $homeRoute');

        // Navegar automáticamente después del login exitoso
        _navigateToHome(homeRoute);
      } else {
        print('❌ LOGIN: No se pudo cargar el perfil desde el backend');
        throw Exception(
          'No se pudo cargar el perfil del usuario desde el backend',
        );
      }
    } catch (e) {
      print('❌ LOGIN: Error cargando perfil desde backend - $e');
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

    print('🔍 LOGIN: Calculando ruta para rol: ${_currentUser!.role}');

    switch (_currentUser!.role) {
      case UserRole.athlete:
        print('✅ LOGIN: Dirigiendo a /boxer-home');
        return '/boxer-home';
      case UserRole.coach:
        print('✅ LOGIN: Dirigiendo a /coach-home');
        return '/coach-home';
      case UserRole.admin:
        print('✅ LOGIN: Dirigiendo a /admin-home');
        return '/admin-home';
    }
  }

  /// Verificar si el usuario necesita vinculación usando GET /users/me
  Future<bool> needsGymKeyActivation() async {
    try {
      if (_currentUser == null) return false;

      // 🔧 CORRECCIÓN IMPLEMENTADA: Admins tienen gimnasio automático
      if (_currentUser!.role == UserRole.admin) {
        print('👑 LOGIN: Usuario es ADMIN - Gimnasio creado automáticamente');
        return false;
      }

      print(
        '🔍 LOGIN: Verificando vinculación con GET /users/me para ${_currentUser!.role}',
      );

      // Llamar a GET /users/me para verificar estado según backend
      final response = await _apiService.getUserMe();
      final userData = response.data;

      // 🔧 CORRECCIÓN IMPLEMENTADA: Verificar relación gyms para coaches/atletas
      final gimnasio = userData['gimnasio'];
      final gyms = userData['gyms'] as List?;

      // Coaches y atletas necesitan estar en la lista 'gyms'
      final needsLink = gimnasio == null && (gyms == null || gyms.isEmpty);

      print('🏋️ LOGIN: Estado gimnasio: ${gimnasio ?? "null"}');
      print('👥 LOGIN: Lista gyms: ${gyms?.length ?? 0} elementos');
      print('📊 LOGIN: Necesita vinculación: $needsLink');

      return needsLink;
    } catch (e) {
      print('❌ LOGIN: Error verificando vinculación - $e');

      // 🔧 CORRECCIÓN IMPLEMENTADA: Admins nunca necesitan vinculación
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

  /// Auto-fix para coaches pendientes
  Future<void> autoFixCoachStatus() async {
    try {
      if (_currentUser?.role != UserRole.coach) return;

      print('🔧 LOGIN: Verificando si coach necesita auto-fix...');

      final response = await _apiService.getUserMe();
      final userData = response.data;

      if (userData['estado_atleta'] == 'pendiente_datos') {
        print('⚠️ LOGIN: Coach pendiente detectado, ejecutando auto-fix...');

        // Intentar ejecutar el fix automáticamente
        try {
          await _apiService.post(
            '/identity/v1/usuarios/fix-coaches-estado',
            data: {},
          );
          print('✅ LOGIN: Auto-fix ejecutado exitosamente');
        } catch (e) {
          print('❌ LOGIN: Auto-fix falló, pero continuando...');
        }
      }
    } catch (e) {
      print('❌ LOGIN: Error en auto-fix - $e');
    }
  }

  /// Obtener ruta considerando el estado de activación y estado del atleta
  Future<String> getRouteWithActivationCheck() async {
    if (_currentUser == null) return '/login';

    print('🔍 LOGIN: getRouteWithActivationCheck - Rol: ${_currentUser!.role}');

    // Verificar si necesita activación
    final needsActivation = await needsGymKeyActivation();

    if (needsActivation) {
      print('🔑 LOGIN: Necesita activación - /gym-key-required');
      return '/gym-key-required';
    }

    // Para atletas, verificar estado adicional
    if (_currentUser!.role == UserRole.athlete) {
      try {
        print('🏃 LOGIN: Verificando estado del atleta...');
        final response = await _apiService.getUserMe();
        final userData = response.data;
        final estadoAtleta = userData['estado_atleta'];
        final datosFisicosCapturados = userData['datos_fisicos_capturados'];

        print('📊 LOGIN: Estado atleta: $estadoAtleta');
        print('📊 LOGIN: Datos físicos capturados: $datosFisicosCapturados');

        // Si está pendiente de datos, ir al home (que mostrará mensaje de espera)
        if (estadoAtleta == 'pendiente_datos' ||
            datosFisicosCapturados == false) {
          print('⏳ LOGIN: Atleta en espera de datos físicos - ir a home');
          return '/boxer-home';
        }

        // Si está activo, ir al home normal
        if (estadoAtleta == 'activo' || datosFisicosCapturados == true) {
          print('✅ LOGIN: Atleta activo - ir a home normal');
          return '/boxer-home';
        }

        // Si está inactivo, también ir al home (mostrará estado)
        if (estadoAtleta == 'inactivo') {
          print('❌ LOGIN: Atleta inactivo - ir a home');
          return '/boxer-home';
        }

        // Estado desconocido, ir al home
        print('❓ LOGIN: Estado atleta desconocido - ir a home');
        return '/boxer-home';
      } catch (e) {
        print('❌ LOGIN: Error verificando estado del atleta - $e');
        // En caso de error, ir al home (manejará el error)
        return '/boxer-home';
      }
    }

    // Para coaches y admins, usar ruta normal
    final homeRoute = getHomeRoute();
    print('🏠 LOGIN: Ruta calculada para ${_currentUser!.role}: $homeRoute');
    print('🔍 LOGIN: ¿Es coach? ${_currentUser!.role == UserRole.coach}');
    print('🔍 LOGIN: ¿Es athlete? ${_currentUser!.role == UserRole.athlete}');
    print('🔍 LOGIN: ¿Es admin? ${_currentUser!.role == UserRole.admin}');
    print('🏠 LOGIN: Ruta final devuelta: $homeRoute');
    return homeRoute;
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

  /// Navegar al home correspondiente
  void _navigateToHome(String route) {
    print('🚀 LOGIN: Navegando a: $route');
    print('🔍 LOGIN: Rol actual: ${_currentUser?.role}');
    print('🔍 LOGIN: ¿Es coach? ${_currentUser?.role == UserRole.coach}');
    print('🔍 LOGIN: ¿Es athlete? ${_currentUser?.role == UserRole.athlete}');
    print('🔍 LOGIN: ¿Es admin? ${_currentUser?.role == UserRole.admin}');

    // La navegación se maneja desde el widget que escucha el estado
    // Aquí solo loggeamos la ruta calculada
  }

  /// Parsear rol desde string
  UserRole _parseRole(String? roleString) {
    print('🔍 LOGIN: Parseando rol: "$roleString"');
    print('🔍 LOGIN: Rol en minúsculas: "${roleString?.toLowerCase()}"');

    switch (roleString?.toLowerCase()) {
      case 'atleta':
      case 'athlete':
      case 'boxer':
      case 'boxeador':
        print('✅ LOGIN: Rol parseado como ATHLETE');
        return UserRole.athlete;
      case 'entrenador':
      case 'coach':
      case 'trainer':
      case 'instructor':
        print('✅ LOGIN: Rol parseado como COACH');
        return UserRole.coach;
      case 'administrador':
      case 'admin':
      case 'administrator':
        print('✅ LOGIN: Rol parseado como ADMIN');
        return UserRole.admin;
      default:
        print(
          '⚠️ LOGIN: Rol desconocido: "$roleString" - usando default: athlete',
        );
        print('⚠️ LOGIN: Valor exacto del rol: "$roleString"');
        print('⚠️ LOGIN: Longitud del rol: ${roleString?.length}');
        print('⚠️ LOGIN: Caracteres del rol: ${roleString?.codeUnits}');
        return UserRole.athlete; // Default
    }
  }

  /// Helpers privados
  void _setState(AWSLoginState newState) {
    print('🔄 LOGIN: Cambiando estado de $_state a $newState');
    print('🔍 LOGIN: Rol actual: ${_currentUser?.role}');
    print('🔍 LOGIN: ¿Es coach? ${_currentUser?.role == UserRole.coach}');
    print('🔍 LOGIN: ¿Es athlete? ${_currentUser?.role == UserRole.athlete}');
    print('🔍 LOGIN: ¿Es admin? ${_currentUser?.role == UserRole.admin}');

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
