import 'package:flutter/foundation.dart';
import '../../../../core/services/aws_api_service.dart';
import '../../../../core/services/aws_auth_service.dart';

/// Estados para la activación con clave del gimnasio
enum GymKeyActivationState { initial, loading, activated, error }

/// Cubit para manejar la activación de cuenta con clave del gimnasio
class GymKeyActivationCubit extends ChangeNotifier {
  final AWSApiService _apiService;
  final AWSAuthService _authService;

  GymKeyActivationState _state = GymKeyActivationState.initial;
  String? _errorMessage;
  bool _isActivated = false;

  GymKeyActivationCubit(this._apiService, this._authService);

  // Getters
  GymKeyActivationState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == GymKeyActivationState.loading;
  bool get isActivated => _isActivated;
  bool get hasError => _state == GymKeyActivationState.error;

  /// Vincular cuenta con gimnasio usando nueva API del backend
  Future<void> activateWithGymKey(String gymKey) async {
    try {
      print('🔗 VINCULACIÓN: Iniciando vinculación con gimnasio');
      print('🏋️ Clave: $gymKey');

      _setState(GymKeyActivationState.loading);
      _clearError();

      // PASO 1: Vincular cuenta con gimnasio (NUEVO ENDPOINT)
      final response = await _apiService.linkAccountToGym(gymKey);
      print('✅ VINCULACIÓN: Cuenta vinculada exitosamente');

      // PASO 2: La respuesta contiene el PerfilUsuarioDto completo
      // No necesitamos actualizar Cognito, el backend maneja todo
      print('📊 VINCULACIÓN: Datos recibidos del backend');

      // PASO 3: Marcar como activado
      _isActivated = true;
      _setState(GymKeyActivationState.activated);

      print('🎉 VINCULACIÓN: Proceso completado exitosamente');
    } catch (e) {
      print('❌ ACTIVACIÓN: Error - $e');

      // Manejar diferentes tipos de errores
      String errorMessage = 'Error activando cuenta';

      if (e.toString().contains('403') || e.toString().contains('forbidden')) {
        errorMessage =
            'Clave inválida. Verifica con tu entrenador/administrador.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'La clave no existe. Contacta con el administrador.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Tu sesión ha expirado. Inicia sesión nuevamente.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = 'Error de conexión. Verifica tu internet.';
      }

      _setError(errorMessage);
      _setState(GymKeyActivationState.error);
    }
  }

  /// Verificar si el usuario necesita activación
  Future<bool> needsActivation() async {
    try {
      print('🔍 VINCULACIÓN: Verificando estado del usuario con GET /users/me');

      // Obtener información del usuario desde el backend (NUEVO FLUJO)
      final response = await _apiService.getUserMe();
      final userData = response.data;

      print('📊 VINCULACIÓN: Datos recibidos del backend: $userData');

      // Verificar si el campo 'gimnasio' es null según especificación del backend
      final gimnasio = userData['gimnasio'];
      final needsLink = gimnasio == null;

      print('🏋️ VINCULACIÓN: Gimnasio: ${gimnasio ?? "null"}');
      print('📊 VINCULACIÓN: Necesita vinculación: $needsLink');

      return needsLink;
    } catch (e) {
      print('❌ VINCULACIÓN: Error verificando vinculación - $e');

      // 🚨 NOTA: Este cubit solo debería usarse para boxers/coaches
      // Los admins no deberían llegar aquí nunca
      print('⚠️ VINCULACIÓN: Error de red - asumir que necesita vinculación');
      return true; // En caso de error, asumir que necesita vinculación
    }
  }

  /// Obtener rol del usuario actual
  Future<String?> getUserRole() async {
    try {
      final attributes = await _authService.getUserAttributes();

      for (final attr in attributes) {
        if (attr.userAttributeKey.key == 'custom:rol') {
          return attr.value;
        }
      }

      return null;
    } catch (e) {
      print('❌ ACTIVACIÓN: Error obteniendo rol - $e');
      return null;
    }
  }

  /// Reiniciar estado
  void reset() {
    _state = GymKeyActivationState.initial;
    _errorMessage = null;
    _isActivated = false;
    notifyListeners();
  }

  /// Helpers privados
  void _setState(GymKeyActivationState newState) {
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
