import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

/// Servicio de autenticación usando AWS Cognito via Amplify
/// Reemplaza el sistema OAuth2 anterior
class AWSAuthService {
  /// Registrar un nuevo usuario en Cognito
  Future<SignUpResult> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String role, // 'atleta', 'entrenador', 'administrador'
    String? gymKey, // OPCIONAL: solo para boxeadores y entrenadores
  }) async {
    try {
      print('🚀 AWS: Iniciando registro de usuario');
      print('📧 Email: $email');
      print('👤 Nombre: $fullName');
      print('🎭 Rol: $role');
      print('🏋️ Clave Gym: ${gymKey ?? 'N/A (Administrador)'}');

      // Construir atributos base
      final Map<AuthUserAttributeKey, String> userAttributes = {
        AuthUserAttributeKey.email: email,
        AuthUserAttributeKey.name: fullName,
        const CognitoUserAttributeKey.custom('rol'): role,
      };

      // Solo agregar claveGym para boxeadores y entrenadores
      if (gymKey != null && gymKey.isNotEmpty) {
        userAttributes[const CognitoUserAttributeKey.custom('claveGym')] =
            gymKey;
        print('✅ AWS: Incluyendo claveGym para $role');
      } else {
        print('✅ AWS: NO incluyendo claveGym para $role (Administrador)');
      }

      final result = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(userAttributes: userAttributes),
      );

      print('✅ AWS: Usuario registrado exitosamente');
      print('🔍 Resultado: ${result.toString()}');

      return result;
    } on AuthException catch (e) {
      print('❌ AWS: Error en registro - ${e.message}');
      print('🔍 Detalles: ${e.toString()}');
      rethrow;
    } catch (e) {
      print('❌ AWS: Error inesperado en registro - $e');
      rethrow;
    }
  }

  /// Confirmar registro con código enviado por email
  Future<SignUpResult> confirmSignUp({
    required String email,
    required String confirmationCode,
  }) async {
    try {
      print('🚀 AWS: Confirmando registro');
      print('📧 Email: $email');
      print('🔢 Código: $confirmationCode');

      final result = await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );

      print('✅ AWS: Registro confirmado exitosamente');
      return result;
    } on AuthException catch (e) {
      print('❌ AWS: Error en confirmación - ${e.message}');
      rethrow;
    }
  }

  /// Iniciar sesión con email y contraseña
  Future<SignInResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🚀 AWS: Iniciando sesión');
      print('📧 Email: $email');

      final result = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );

      print('✅ AWS: Sesión iniciada exitosamente');
      print('🔍 Usuario autenticado: ${result.isSignedIn}');

      return result;
    } on AuthException catch (e) {
      print('❌ AWS: Error en inicio de sesión - ${e.message}');
      rethrow;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      print('🚀 AWS: Cerrando sesión');

      await Amplify.Auth.signOut();

      print('✅ AWS: Sesión cerrada exitosamente');
    } on AuthException catch (e) {
      print('❌ AWS: Error al cerrar sesión - ${e.message}');
      rethrow;
    }
  }

  /// Obtener la sesión actual del usuario
  Future<AuthSession> getCurrentSession() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      print('🔍 AWS: Sesión actual obtenida');
      print('✅ Autenticado: ${session.isSignedIn}');

      return session;
    } on AuthException catch (e) {
      print('❌ AWS: Error obteniendo sesión - ${e.message}');
      rethrow;
    }
  }

  /// Obtener token de acceso JWT para llamadas API
  Future<String?> getAccessToken() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();

      if (session.isSignedIn) {
        final cognitoSession = session as CognitoAuthSession;
        final accessToken =
            cognitoSession.userPoolTokensResult.value.accessToken.raw;

        print('🔑 AWS: Token de acceso obtenido');
        return accessToken;
      } else {
        print('⚠️ AWS: Usuario no autenticado');
        return null;
      }
    } on AuthException catch (e) {
      print('❌ AWS: Error obteniendo token - ${e.message}');
      return null;
    }
  }

  /// Obtener información del usuario actual
  Future<AuthUser?> getCurrentUser() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      print('👤 AWS: Usuario actual obtenido - ${user.username}');
      return user;
    } on AuthException catch (e) {
      print('❌ AWS: Error obteniendo usuario - ${e.message}');
      return null;
    }
  }

  /// Verificar si el usuario está autenticado
  Future<bool> isSignedIn() async {
    try {
      final session = await getCurrentSession();
      return session.isSignedIn;
    } catch (e) {
      print('❌ AWS: Error verificando autenticación - $e');
      return false;
    }
  }

  /// Obtener atributos del usuario (incluyendo rol y gym)
  Future<List<AuthUserAttribute>> getUserAttributes() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      print('📋 AWS: Atributos de usuario obtenidos');

      for (final attr in attributes) {
        print('🔍 ${attr.userAttributeKey}: ${attr.value}');
      }

      return attributes;
    } on AuthException catch (e) {
      print('❌ AWS: Error obteniendo atributos - ${e.message}');
      rethrow;
    }
  }

  /// Reenviar código de confirmación
  Future<ResendSignUpCodeResult> resendSignUpCode({
    required String email,
  }) async {
    try {
      print('🚀 AWS: Reenviando código de confirmación');
      print('📧 Email: $email');

      final result = await Amplify.Auth.resendSignUpCode(username: email);

      print('✅ AWS: Código reenviado exitosamente');
      return result;
    } on AuthException catch (e) {
      print('❌ AWS: Error reenviando código - ${e.message}');
      rethrow;
    }
  }

  /// Actualizar atributo personalizado del usuario
  Future<void> updateUserAttribute(String attributeName, String value) async {
    try {
      print('🔄 AWS: Actualizando atributo $attributeName');
      print('📝 Valor: ${attributeName.contains('clave') ? '***' : value}');

      final attributeKey = CognitoUserAttributeKey.custom(attributeName);

      await Amplify.Auth.updateUserAttribute(
        userAttributeKey: attributeKey,
        value: value,
      );

      print('✅ AWS: Atributo $attributeName actualizado exitosamente');
    } on AuthException catch (e) {
      print('❌ AWS: Error actualizando atributo $attributeName - ${e.message}');
      rethrow;
    }
  }
}
