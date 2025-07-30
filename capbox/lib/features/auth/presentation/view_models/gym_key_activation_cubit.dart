import 'package:flutter/foundation.dart';
import '../../../../core/services/aws_api_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/user_display_service.dart';

/// Estados para la activación con clave del gimnasio
enum GymKeyActivationState { initial, loading, activated, error }

/// Cubit para manejar la activación de cuenta con clave del gimnasio
class GymKeyActivationCubit extends ChangeNotifier {
  final AWSApiService _apiService;
  final AuthService _authService;

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

      // 🔧 CORRECCIÓN IMPLEMENTADA: Usar endpoint actualizado
      await _apiService.linkAccountToGym(gymKey);
      print('✅ VINCULACIÓN: Cuenta vinculada exitosamente');

      // 🔧 CORRECCIÓN IMPLEMENTADA: Backend maneja upsert automáticamente
      print('📊 VINCULACIÓN: Backend actualizó usuario con upsert()');

      // PASO 3: Limpiar caché de usuario para forzar recarga
      UserDisplayService.clearGlobalCache();
      print('🗑️ VINCULACIÓN: Caché de usuario limpiado');

      // PASO 4: Marcar como activado
      _isActivated = true;
      _setState(GymKeyActivationState.activated);

      print('🎉 VINCULACIÓN: Proceso completado exitosamente');
    } catch (e) {
      print('❌ ACTIVACIÓN: Error - $e');

      // 🔧 CORRECCIÓN IMPLEMENTADA: Manejar errores específicos del nuevo backend
      String errorMessage = 'Error activando cuenta';

      if (e.toString().contains('403') || e.toString().contains('forbidden')) {
        errorMessage =
            'Clave inválida. Verifica con tu entrenador/administrador.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'La clave no existe. Contacta con el administrador.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Tu sesión ha expirado. Inicia sesión nuevamente.';
      } else if (e.toString().contains('unique constraint') ||
          e.toString().contains('already exists')) {
        errorMessage = 'Ya estás vinculado a este gimnasio.';
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

      // Obtener información del usuario desde el backend
      final response = await _apiService.getUserMe();
      final userData = response.data;

      print('📊 VINCULACIÓN: Datos recibidos del backend: $userData');

      // 🔧 CORRECCIÓN IMPLEMENTADA: Verificar relación gyms para coaches/atletas
      final gimnasio = userData['gimnasio'];
      final gyms = userData['gyms'] as List?;

      // Coaches y atletas necesitan estar en la lista 'gyms'
      final needsLink = gimnasio == null && (gyms == null || gyms.isEmpty);

      print('🏋️ VINCULACIÓN: Gimnasio: ${gimnasio ?? "null"}');
      print('👥 VINCULACIÓN: Lista gyms: ${gyms?.length ?? 0} elementos');
      print('📊 VINCULACIÓN: Necesita vinculación: $needsLink');

      return needsLink;
    } catch (e) {
      print('❌ VINCULACIÓN: Error verificando vinculación - $e');

      // 🔧 CORRECCIÓN IMPLEMENTADA: Este cubit solo para boxers/coaches
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
        final key = attr['name'];
        final value = attr['value'];

        if (key == 'custom:role') {
          return value;
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
