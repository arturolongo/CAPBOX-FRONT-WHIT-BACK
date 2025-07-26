import 'package:dio/dio.dart';
import '../../../../core/api/api_config.dart';
import '../dtos/oauth_token_request_dto.dart';
import '../dtos/oauth_token_response_dto.dart';
import '../dtos/register_request_dto.dart';
import '../dtos/user_profile_dto.dart';

class AuthApiClient {
  final Dio _dio;

  AuthApiClient(this._dio);

  /// OAuth2 Login - Obtiene access_token y refresh_token
  Future<OAuthTokenResponseDto> login(OAuthTokenRequestDto dto) async {
    final response = await _dio.post(
      ApiConfig.getIdentidadUrl(ApiConfig.oauthToken),
      data: dto.toJson(),
    );
    return OAuthTokenResponseDto.fromJson(response.data);
  }

  /// Registro de nuevo usuario
  Future<RegisterResponseDto> register(RegisterRequestDto dto) async {
    final response = await _dio.post(
      ApiConfig.getIdentidadUrl(ApiConfig.register),
      data: dto.toJson(),
    );
    return RegisterResponseDto.fromJson(response.data);
  }

  /// Obtener perfil del usuario autenticado
  Future<UserProfileDto> getUserProfile(String token) async {
    final response = await _dio.get(
      ApiConfig.getIdentidadUrl(ApiConfig.userProfile),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return UserProfileDto.fromJson(response.data);
  }

  /// Refresh token cuando expire el access_token
  Future<OAuthTokenResponseDto> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      ApiConfig.getIdentidadUrl(ApiConfig.oauthToken),
      data: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': ApiConfig.oauthClientId,
        'client_secret': ApiConfig.oauthClientSecret,
      },
    );
    return OAuthTokenResponseDto.fromJson(response.data);
  }

  /// Obtener solicitudes pendientes (para entrenadores)
  Future<List<Map<String, dynamic>>> getPendingRequests(String token) async {
    final response = await _dio.get(
      ApiConfig.getIdentidadUrl(ApiConfig.pendingRequests),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Aprobar atleta (para entrenadores)
  Future<Map<String, dynamic>> approveAthlete(
    String athleteId,
    String token,
  ) async {
    final response = await _dio.post(
      ApiConfig.getIdentidadUrl(ApiConfig.approveAthlete(athleteId)),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  /// Obtener miembros del gimnasio (para entrenadores)
  Future<List<Map<String, dynamic>>> getGymMembers(
    String gymId,
    String token,
  ) async {
    final response = await _dio.get(
      ApiConfig.getIdentidadUrl(ApiConfig.gymMembers(gymId)),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }
}
