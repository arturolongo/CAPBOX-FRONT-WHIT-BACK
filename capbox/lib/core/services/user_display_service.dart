import 'aws_auth_service.dart';
import 'aws_api_service.dart';

/// Servicio para obtener datos de display del usuario actual (CON CACHÉ)
class UserDisplayService {
  final AWSAuthService _authService;
  final AWSApiService _apiService;

  // 💾 CACHÉ PARA EVITAR CARGAS REPETIDAS
  UserDisplayData? _cachedData;
  bool _isLoading = false;
  DateTime? _lastLoadTime;

  // 🌍 INSTANCIA GLOBAL PARA LIMPIAR DESDE CUALQUIER LUGAR
  static UserDisplayService? _globalInstance;

  UserDisplayService(this._authService, this._apiService) {
    _globalInstance = this; // Guardar referencia global
  }

  /// Obtener datos de display del usuario actual (CON CACHÉ INTELIGENTE)
  Future<UserDisplayData> getCurrentUserDisplayData({
    bool forceRefresh = false,
  }) async {
    // 🚀 RETORNAR CACHÉ SI EXISTE Y NO SE FUERZA REFRESH
    if (!forceRefresh && _cachedData != null && !_isCacheExpired()) {
      print('💾 DISPLAY: Usando datos cacheados (evitando carga innecesaria)');
      return _cachedData!;
    }

    // 🔄 EVITAR MÚLTIPLES CARGAS SIMULTÁNEAS
    if (_isLoading) {
      print('⏳ DISPLAY: Carga ya en progreso, esperando...');
      // Esperar a que termine la carga actual
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      // Si ya se cargó mientras esperábamos, devolverlo
      if (_cachedData != null) return _cachedData!;
    }

    return await _loadUserDataFromBackend(forceRefresh);
  }

  /// 🔄 Cargar datos desde el backend (MÉTODO PRIVADO)
  Future<UserDisplayData> _loadUserDataFromBackend(bool isRefresh) async {
    _isLoading = true;

    try {
      if (isRefresh) {
        print('🔄 DISPLAY: Refrescando datos del usuario...');
      } else {
        print('👤 DISPLAY: Cargando datos del usuario por primera vez...');
      }

      // Obtener usuario de Cognito
      final cognitoUser = await _authService.getCurrentUser();
      final attributes = await _authService.getUserAttributes();

      if (cognitoUser == null) {
        throw Exception('Usuario no encontrado');
      }

      String? name;
      String? role;
      String? email = cognitoUser.username;

      // Extraer atributos de Cognito
      for (final attr in attributes) {
        switch (attr.userAttributeKey.key) {
          case 'name':
            name = attr.value;
            break;
          case 'custom:rol':
            role = attr.value;
            break;
        }
      }

      // Obtener primer nombre (antes del primer espacio)
      final firstName = name?.split(' ').first ?? 'Usuario';

      // Para admin, obtener nombre del gimnasio
      String displayName = firstName;
      if (role?.toLowerCase() == 'administrador') {
        try {
          final gymResponse = await _apiService.getAdminGymKey();
          final gymName =
              gymResponse.data['nombreGimnasio'] ??
              gymResponse.data['gymName'] ??
              gymResponse.data['claveGym'] ?? // Usar clave como fallback
              'Gym Admin';
          displayName = gymName;
        } catch (e) {
          print(
            '⚠️ DISPLAY: Backend no disponible, usando displayName genérico',
          );
          displayName = 'Administrador';
        }
      }

      // Obtener inicial para avatar
      final avatarInitial =
          firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U';

      // 💾 GUARDAR EN CACHÉ
      _cachedData = UserDisplayData(
        fullName: name ?? 'Usuario',
        firstName: firstName,
        displayName: displayName,
        avatarInitial: avatarInitial,
        role: role ?? 'usuario',
        email: email ?? '',
      );

      _lastLoadTime = DateTime.now();
      _isLoading = false;

      print('✅ DISPLAY: Datos cargados y cacheados exitosamente');
      print('👤 ${_cachedData!.fullName} (${_cachedData!.role})');

      return _cachedData!;
    } catch (e) {
      _isLoading = false;
      print('❌ DISPLAY: Error cargando datos - $e');

      // Si hay caché previo, usarlo como fallback
      if (_cachedData != null) {
        print('💾 DISPLAY: Usando datos cacheados previos como fallback');
        return _cachedData!;
      }

      // Retornar datos por defecto solo si no hay caché
      _cachedData = UserDisplayData(
        fullName: 'Usuario',
        firstName: 'Usuario',
        displayName: 'Usuario',
        avatarInitial: 'U',
        role: 'usuario',
        email: '',
      );
      return _cachedData!;
    }
  }

  /// 🕒 Verificar si el caché ha expirado (15 minutos)
  bool _isCacheExpired() {
    if (_lastLoadTime == null) return true;
    final now = DateTime.now();
    final diff = now.difference(_lastLoadTime!);
    return diff.inMinutes > 15; // Caché expira en 15 minutos
  }

  /// 🔄 Refrescar datos forzadamente (útil para pulls-to-refresh)
  Future<UserDisplayData> refreshUserData() async {
    print('🔄 DISPLAY: Refresh manual solicitado');
    return await getCurrentUserDisplayData(forceRefresh: true);
  }

  /// 🗑️ Limpiar caché (útil para logout)
  void clearCache() {
    print('🗑️ DISPLAY: Limpiando caché de usuario');
    _cachedData = null;
    _lastLoadTime = null;
    _isLoading = false;
  }

  /// 💾 Verificar si hay datos en caché
  bool get hasCachedData => _cachedData != null;

  /// ⏳ Verificar si está cargando
  bool get isLoading => _isLoading;

  /// 🌍 Limpiar caché globalmente (útil para logout desde cualquier lugar)
  static void clearGlobalCache() {
    if (_globalInstance != null) {
      print('🌍 DISPLAY: Limpiando caché global desde logout');
      _globalInstance!.clearCache();
    }
  }

  /// Obtener solo el nombre para display (CON CACHÉ)
  Future<String> getDisplayName() async {
    try {
      final userData = await getCurrentUserDisplayData();
      return userData.displayName;
    } catch (e) {
      return 'Usuario';
    }
  }

  /// Obtener solo la inicial para el avatar (CON CACHÉ)
  Future<String> getAvatarInitial() async {
    try {
      final userData = await getCurrentUserDisplayData();
      return userData.avatarInitial;
    } catch (e) {
      return 'U';
    }
  }
}

/// Modelo para los datos de display del usuario
class UserDisplayData {
  final String fullName; // Nombre completo
  final String firstName; // Primer nombre
  final String displayName; // Nombre a mostrar (firstName o gymName para admin)
  final String avatarInitial; // Inicial para avatar
  final String role; // Rol del usuario
  final String email; // Email del usuario

  UserDisplayData({
    required this.fullName,
    required this.firstName,
    required this.displayName,
    required this.avatarInitial,
    required this.role,
    required this.email,
  });

  /// Verificar si es admin
  bool get isAdmin => role.toLowerCase() == 'administrador';

  /// Verificar si es entrenador
  bool get isCoach => role.toLowerCase() == 'entrenador';

  /// Verificar si es boxeador
  bool get isBoxer =>
      role.toLowerCase() == 'boxeador' || role.toLowerCase() == 'atleta';
}
