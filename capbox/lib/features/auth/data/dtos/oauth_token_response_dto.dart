class OAuthTokenResponseDto {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  OAuthTokenResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory OAuthTokenResponseDto.fromJson(Map<String, dynamic> json) {
    return OAuthTokenResponseDto(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'token_type': tokenType,
    'expires_in': expiresIn,
  };
}
