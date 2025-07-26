import '../../../../core/api/api_config.dart';

class OAuthTokenRequestDto {
  final String grantType;
  final String clientId;
  final String clientSecret;
  final String username; // Mapeado a email
  final String password;

  OAuthTokenRequestDto({required this.username, required this.password})
    : grantType = 'password',
      clientId = ApiConfig.oauthClientId,
      clientSecret = ApiConfig.oauthClientSecret;

  Map<String, dynamic> toJson() => {
    'grant_type': grantType,
    'client_id': clientId,
    'client_secret': clientSecret,
    'username': username,
    'password': password,
  };
}
