import 'package:flutter/foundation.dart';
import '../../data/services/admin_gym_key_service.dart';

/// Estados para la gestión de la clave del gimnasio por el admin
enum AdminGymKeyState { initial, loading, loaded, saving, error }

/// Cubit para que el admin gestione la clave del gimnasio
class AdminGymKeyCubit extends ChangeNotifier {
  final AdminGymKeyService _keyService;

  AdminGymKeyState _state = AdminGymKeyState.initial;
  String? _gymKey;
  String? _errorMessage;

  AdminGymKeyCubit(this._keyService);

  // Getters
  AdminGymKeyState get state => _state;
  String? get gymKey => _gymKey;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AdminGymKeyState.loading;
  bool get isSaving => _state == AdminGymKeyState.saving;
  bool get hasError => _state == AdminGymKeyState.error;
  bool get hasData => _gymKey != null;

  /// Cargar la clave actual del gimnasio
  Future<void> loadGymKey() async {
    try {
      _setState(AdminGymKeyState.loading);
      _clearError();

      print('🗝️ ADMIN CUBIT: Cargando clave del gimnasio');

      _gymKey = await _keyService.getGymKey();

      print('✅ ADMIN CUBIT: Clave cargada - $_gymKey');

      _setState(AdminGymKeyState.loaded);
    } catch (e) {
      print('❌ ADMIN CUBIT: Error cargando clave - $e');
      _setError('Error cargando clave del gimnasio: $e');
      _setState(AdminGymKeyState.error);
    }
  }

  /// Actualizar la clave del gimnasio
  Future<void> updateGymKey(String newKey) async {
    try {
      _setState(AdminGymKeyState.saving);
      _clearError();

      print('🗝️ ADMIN CUBIT: Actualizando clave a: $newKey');

      await _keyService.updateGymKey(newKey);

      // Actualizar el valor local
      _gymKey = newKey;

      print('✅ ADMIN CUBIT: Clave actualizada exitosamente');

      _setState(AdminGymKeyState.loaded);
    } catch (e) {
      print('❌ ADMIN CUBIT: Error actualizando clave - $e');
      _setError('Error actualizando clave del gimnasio: $e');
      _setState(AdminGymKeyState.error);
    }
  }

  /// Generar una nueva clave basada en el nombre del gimnasio
  String generateNewKey(String gymName) {
    return _keyService.generateNewKey(gymName);
  }

  /// Validar formato de clave según el nuevo estándar
  bool isValidKeyFormat(String key, String gymName) {
    return _keyService.isValidKeyFormat(key, gymName);
  }

  /// Obtener el prefijo esperado para un gimnasio
  String getExpectedPrefix(String gymName) {
    return _keyService.getExpectedPrefix(gymName);
  }

  /// Activar coaches existentes (fix temporal)
  Future<Map<String, dynamic>> activarCoachesExistentes() async {
    try {
      print('🔧 ADMIN CUBIT: Activando coaches existentes...');

      final result = await _keyService.activarCoachesExistentes();

      print('✅ ADMIN CUBIT: Coaches activados exitosamente');

      return result;
    } catch (e) {
      print('❌ ADMIN CUBIT: Error activando coaches - $e');
      rethrow;
    }
  }

  /// Helpers privados
  void _setState(AdminGymKeyState newState) {
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
