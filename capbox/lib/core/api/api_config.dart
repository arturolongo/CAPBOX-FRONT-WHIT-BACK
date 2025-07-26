import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Base URLs de los microservicios desde .env
  static String get identidadBaseUrl =>
      dotenv.env['IDENTIDAD_BASE_URL'] ?? 'https://api.capbox.site';

  static String get planificacionBaseUrl =>
      dotenv.env['PLANIFICACION_BASE_URL'] ?? 'https://api.capbox.site';

  // OAuth2 Credentials desde .env
  static String get oauthClientId =>
      dotenv.env['OAUTH_CLIENT_ID'] ?? 'capbox_mobile_app_prod';

  static String get oauthClientSecret =>
      dotenv.env['OAUTH_CLIENT_SECRET'] ??
      'UN_SECRETO_DE_PRODUCCION_MUY_LARGO_Y_SEGURO';

  // Auth endpoints (ms-identidad)
  static const String register = '/v1/auth/register';
  static const String oauthToken = '/v1/oauth/token';
  static const String userProfile = '/v1/users/me';
  static const String userGymKey = '/v1/users/me/gym/key';
  static const String pendingRequests = '/v1/requests/pending';
  static String approveAthlete(String athleteId) =>
      '/v1/athletes/$athleteId/approve';
  static String gymMembers(String gymId) => '/v1/gyms/$gymId/members';

  // Planning endpoints (ms-planificacion)
  static const String routines = '/v1/planning/routines';
  static String routineById(String id) => '/v1/planning/routines/$id';
  static String routinesFiltered(String nivel) =>
      '/v1/planning/routines?nivel=$nivel';
  static const String myAssignments = '/v1/planning/assignments/me';

  // Helper methods
  static String getIdentidadUrl(String endpoint) => identidadBaseUrl + endpoint;
  static String getPlanificacionUrl(String endpoint) =>
      planificacionBaseUrl + endpoint;

  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
