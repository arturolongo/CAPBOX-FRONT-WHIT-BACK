import 'package:flutter/foundation.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/aws_api_service.dart';

/// Estados del registro con OAuth2
enum AWSRegisterState {
  initial,
  registering,
  awaitingConfirmation,
  success,
  error,
}

/// Cubit para manejar el registro de usuarios con OAuth2
class AWSRegisterCubit extends ChangeNotifier {
  final AuthService _authService;
  final AWSApiService _apiService;

  AWSRegisterState _state = AWSRegisterState.initial;
  String? _errorMessage;
  String? _successMessage;
  String? _pendingEmail; // Email esperando confirmación

  AWSRegisterCubit(this._authService, this._apiService);

  // Getters
  AWSRegisterState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get pendingEmail => _pendingEmail;
  bool get isLoading => _state == AWSRegisterState.registering;
  bool get isAwaitingConfirmation =>
      _state == AWSRegisterState.awaitingConfirmation;

  /// Registrar un nuevo usuario
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? gymName, // Para admin - creación automática de gimnasio
  }) async {
    try {
      print('🚀 REGISTRO AWS: Iniciando registro completo');
      print('📧 Email: $email');
      print('👤 Nombre: $fullName');
      print('🎭 Rol: $role');
      if (gymName != null) {
        print('🏋️ Nombre Gimnasio: $gymName');
      }

      _setState(AWSRegisterState.registering);
      _clearMessages();

      // 🔧 CORRECCIÓN IMPLEMENTADA: Manejo diferenciado por rol
      print('🔄 FLUJO ACTUALIZADO: Registro con manejo por rol');

      // PASO 1: Registrar en backend con manejo diferenciado
      print('📱 PASO 1: Registrando en backend...');

      final cognitoResult = await _apiService.registerUser(
        email: email,
        password: password,
        nombre: fullName,
        rol: role,
        nombreGimnasio: gymName, // Para admins: crea gimnasio automáticamente
      );

      print('✅ BACKEND: Usuario registrado exitosamente');
      print('🔍 Estado: Registro exitoso, necesita confirmación');

      // PASO 2: Verificar si necesita confirmación
      if (cognitoResult != null) {
        print('📧 BACKEND: Confirmación requerida via email');
        _pendingEmail = email;
        _setState(AWSRegisterState.awaitingConfirmation);
        _setSuccessMessage(
          'Se ha enviado un código de confirmación a tu email. Por favor, revisa tu bandeja de entrada.',
        );
        return;
      }

      // PASO 3: Si no necesita confirmación, registro completado
      print('✅ REGISTRO: Completado sin confirmación requerida');
      _setState(AWSRegisterState.success);
      _setSuccessMessage(
        '¡Registro completado exitosamente! Ya puedes iniciar sesión.',
      );
    } catch (e) {
      print('❌ REGISTRO ERROR: $e');
      _handleRegistrationError(e);
    }
  }

  /// Confirmar registro con código enviado por email
  Future<void> confirmRegistration(String confirmationCode) async {
    if (_pendingEmail == null) {
      _setErrorMessage('No hay registro pendiente de confirmación');
      return;
    }

    try {
      print('🚀 CONFIRMACIÓN: Confirmando registro con código');
      print('📧 Email: $_pendingEmail');
      print('🔢 Código: $confirmationCode');

      _setState(AWSRegisterState.registering);
      _clearMessages();

      // Confirmar en el backend OAuth2
      final result = await _authService.confirmSignUp(
        email: _pendingEmail!,
        confirmationCode: confirmationCode,
      );

      if (result) {
        print('✅ BACKEND: Registro confirmado exitosamente');
        _setState(AWSRegisterState.success);
        _setSuccessMessage(
          '¡Registro confirmado exitosamente! Ya puedes iniciar sesión.',
        );
        _pendingEmail = null;
      } else {
        print('❌ BACKEND: Error en confirmación');
        _setErrorMessage('Error confirmando el registro. Verifica el código.');
        _setState(AWSRegisterState.error);
      }
    } catch (e) {
      print('❌ CONFIRMACIÓN ERROR: ${e.toString()}');
      _setErrorMessage('Error confirmando el registro: ${e.toString()}');
      _setState(AWSRegisterState.error);
    }
  }

  /// Establecer email pendiente de confirmación
  void setPendingEmail(String email) {
    _pendingEmail = email;
    notifyListeners();
  }

  /// Reenviar código de confirmación
  Future<void> resendConfirmationCode() async {
    if (_pendingEmail == null) {
      _setErrorMessage('No hay registro pendiente de confirmación');
      return;
    }

    try {
      print('🚀 REENVÍO: Reenviando código de confirmación');
      print('📧 Email: $_pendingEmail');

      await _authService.resendSignUpCode(_pendingEmail!);

      print('✅ COGNITO: Código reenviado');
      _setSuccessMessage('Código de confirmación reenviado. Revisa tu email.');
    } catch (e) {
      print('❌ REENVÍO ERROR: ${e.toString()}');
      _setErrorMessage('Error reenviando código: ${e.toString()}');
    } catch (e) {
      print('❌ REENVÍO ERROR: $e');
      _setErrorMessage('Error inesperado reenviando código: $e');
    }
  }

  /// Registrar usuario en el backend (opcional, dependiendo de la arquitectura)
  Future<void> _registerInBackend(
    String email,
    String password,
    String fullName,
    String role,
    String? gymName,
  ) async {
    try {
      print('🚀 BACKEND: Registrando en backend...');

      final response = await _apiService.registerUser(
        email: email,
        password: password,
        nombre: fullName,
        rol: role,
        nombreGimnasio: gymName,
      );

      print('✅ BACKEND: Usuario registrado en backend');
      print('📥 Respuesta: ${response.data}');

      _setState(AWSRegisterState.success);
      _setSuccessMessage(
        '¡Registro completado exitosamente! Ya puedes iniciar sesión.',
      );
    } catch (e) {
      print('❌ BACKEND ERROR: $e');
      // Si falla el backend pero Cognito funcionó, aún consideramos éxito
      // El usuario puede iniciar sesión y los datos se sincronizarán después
      _setState(AWSRegisterState.success);
      _setSuccessMessage(
        'Registro en Cognito exitoso. Inicia sesión para continuar.',
      );
    }
  }

  /// Manejar errores específicos de Cognito
  void _handleCognitoError(Exception e) {
    String userMessage;
    final message = e.toString().toLowerCase();

    if (message.contains('an account with the given email already exists')) {
      userMessage =
          'Ya existe una cuenta con este email. Intenta iniciar sesión.';
    } else if (message.contains('password did not conform with policy')) {
      userMessage = 'La contraseña no cumple con los requisitos de seguridad.';
    } else if (message.contains('invalid verification code provided')) {
      userMessage =
          'Código de verificación inválido. Verifica e intenta de nuevo.';
    } else if (message.contains('user cannot be confirmed')) {
      userMessage = 'El usuario ya está confirmado. Puedes iniciar sesión.';
    } else {
      userMessage = 'Error de autenticación: ${e.toString()}';
    }

    _setErrorMessage(userMessage);
    _setState(AWSRegisterState.error);
  }

  /// Manejar errores de registro con el nuevo backend
  void _handleRegistrationError(dynamic e) {
    String userMessage;
    final message = e.toString().toLowerCase();

    if (message.contains('email already exists') ||
        message.contains('ya existe')) {
      userMessage =
          'Ya existe una cuenta con este email. Intenta iniciar sesión.';
    } else if (message.contains('password') && message.contains('policy')) {
      userMessage = 'La contraseña no cumple con los requisitos de seguridad.';
    } else if (message.contains('validation') ||
        message.contains('validación')) {
      userMessage = 'Datos de registro inválidos. Verifica la información.';
    } else if (message.contains('gym') && message.contains('name')) {
      userMessage = 'El nombre del gimnasio es requerido para administradores.';
    } else if (message.contains('network') || message.contains('connection')) {
      userMessage =
          'Error de conexión. Verifica tu internet e intenta de nuevo.';
    } else {
      userMessage = 'Error durante el registro: ${e.toString()}';
    }

    _setErrorMessage(userMessage);
    _setState(AWSRegisterState.error);
  }

  /// Limpiar estado y volver al inicio
  void reset() {
    _setState(AWSRegisterState.initial);
    _clearMessages();
    _pendingEmail = null;
  }

  /// Helpers privados
  void _setState(AWSRegisterState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setErrorMessage(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccessMessage(String message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
