import 'package:flutter/foundation.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../../../../core/services/aws_auth_service.dart';
import '../../../../core/services/aws_api_service.dart';

/// Estados del registro con AWS Cognito
enum AWSRegisterState {
  initial,
  registering,
  awaitingConfirmation,
  success,
  error,
}

/// Cubit para manejar el registro de usuarios con AWS Cognito
class AWSRegisterCubit extends ChangeNotifier {
  final AWSAuthService _authService;
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
    required String gymKey,
  }) async {
    try {
      print('🚀 REGISTRO AWS: Iniciando registro completo');
      print('📧 Email: $email');
      print('👤 Nombre: $fullName');
      print('🎭 Rol: $role');
      print('🏋️ Clave Gym: $gymKey');

      _setState(AWSRegisterState.registering);
      _clearMessages();

      // NUEVO FLUJO: Sin validación de clave durante registro
      // La clave se solicitará después en el home del usuario
      print('🔄 NUEVO FLUJO: Registro sin clave, se solicitará después');

      // PASO 1: Registrar en AWS Cognito
      print('📱 PASO 1: Registrando en AWS Cognito...');

      // NUEVO FLUJO: NUNCA enviar claveGym durante registro
      // Todos los usuarios se registran sin clave inicialmente
      final cognitoResult = await _authService.registerUser(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        gymKey: null, // ← Siempre null, se solicitará después
      );

      print('✅ COGNITO: Usuario registrado');
      print('🔍 Estado: ${cognitoResult.nextStep.signUpStep}');

      // PASO 2: Verificar si necesita confirmación
      if (cognitoResult.nextStep.signUpStep == AuthSignUpStep.confirmSignUp) {
        print('📧 COGNITO: Confirmación requerida via email');
        _pendingEmail = email;
        _setState(AWSRegisterState.awaitingConfirmation);
        _setSuccessMessage(
          'Se ha enviado un código de confirmación a tu email. Por favor, revisa tu bandeja de entrada.',
        );
        return;
      }

      // PASO 3: Si no necesita confirmación, registrar en backend
      await _registerInBackend(email, password, fullName, role, gymKey);
    } on AuthException catch (e) {
      print('❌ COGNITO ERROR: ${e.message}');
      _handleCognitoError(e);
    } catch (e) {
      print('❌ REGISTRO ERROR: $e');
      _setErrorMessage('Error inesperado durante el registro: $e');
      _setState(AWSRegisterState.error);
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

      _setState(AWSRegisterState.registering);
      _clearMessages();

      // Confirmar en Cognito
      final result = await _authService.confirmSignUp(
        email: _pendingEmail!,
        confirmationCode: confirmationCode,
      );

      print('✅ COGNITO: Registro confirmado exitosamente');

      // TODO: Si es necesario, registrar en backend aquí
      // Por ahora, consideramos el registro completo

      _setState(AWSRegisterState.success);
      _setSuccessMessage(
        '¡Registro confirmado exitosamente! Ya puedes iniciar sesión.',
      );
      _pendingEmail = null;
    } on AuthException catch (e) {
      print('❌ CONFIRMACIÓN ERROR: ${e.message}');
      _handleCognitoError(e);
    } catch (e) {
      print('❌ CONFIRMACIÓN ERROR: $e');
      _setErrorMessage('Error confirmando el registro: $e');
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

      await _authService.resendSignUpCode(email: _pendingEmail!);

      print('✅ COGNITO: Código reenviado');
      _setSuccessMessage('Código de confirmación reenviado. Revisa tu email.');
    } on AuthException catch (e) {
      print('❌ REENVÍO ERROR: ${e.message}');
      _setErrorMessage('Error reenviando código: ${e.message}');
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
    String gymKey,
  ) async {
    try {
      print('🚀 BACKEND: Registrando en backend...');

      final response = await _apiService.registerUser(
        email: email,
        password: password,
        nombre: fullName,
        rol: role,
        claveGym: gymKey,
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
  void _handleCognitoError(AuthException e) {
    String userMessage;

    switch (e.message) {
      case 'An account with the given email already exists.':
        userMessage =
            'Ya existe una cuenta con este email. Intenta iniciar sesión.';
        break;
      case 'Password did not conform with policy':
        userMessage =
            'La contraseña no cumple con los requisitos de seguridad.';
        break;
      case 'Invalid verification code provided, please try again.':
        userMessage =
            'Código de verificación inválido. Verifica e intenta de nuevo.';
        break;
      case 'User cannot be confirmed. Current status is CONFIRMED':
        userMessage = 'El usuario ya está confirmado. Puedes iniciar sesión.';
        break;
      default:
        userMessage = 'Error de autenticación: ${e.message}';
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
