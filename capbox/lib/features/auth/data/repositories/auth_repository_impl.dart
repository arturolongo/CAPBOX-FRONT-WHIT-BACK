import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_api_client.dart';
import '../dtos/oauth_token_request_dto.dart';
import '../dtos/register_request_dto.dart';
import '../mappers/user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<User> login({required String email, required String password}) async {
    // Paso 1: Obtener tokens OAuth2
    final oauthRequest = OAuthTokenRequestDto(
      username: email,
      password: password,
    );

    final tokenResponse = await _apiClient.login(oauthRequest);

    // Paso 2: Obtener perfil del usuario con el access_token
    final userProfile = await _apiClient.getUserProfile(
      tokenResponse.accessToken,
    );

    // Paso 3: Combinar información y crear User
    final user = UserMapper.fromUserProfile(
      userProfile,
      tokenResponse.accessToken,
    );

    return user;
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String nombre,
    required String rol,
  }) async {
    // Convertir string a enum RolUsuario
    RolUsuario rolEnum;
    switch (rol) {
      case 'Atleta':
        rolEnum = RolUsuario.Atleta;
        break;
      case 'Entrenador':
        rolEnum = RolUsuario.Entrenador;
        break;
      case 'Admin':
        rolEnum = RolUsuario.Admin;
        break;
      default:
        throw ArgumentError('Rol inválido: $rol');
    }

    final registerRequest = RegisterRequestDto(
      email: email,
      password: password,
      nombre: nombre,
      rol: rolEnum,
    );

    final response = await _apiClient.register(registerRequest);

    return {
      'success': true,
      'message': response.message,
      'userId': response.data.id,
    };
  }

  Future<User> refreshUserProfile(String token) async {
    final userProfile = await _apiClient.getUserProfile(token);
    return UserMapper.fromUserProfile(userProfile, token);
  }

  Future<String> refreshToken(String refreshToken) async {
    final response = await _apiClient.refreshToken(refreshToken);
    return response.accessToken;
  }
}
