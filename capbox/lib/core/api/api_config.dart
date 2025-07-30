import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de endpoints de la API
class ApiConfig {
  // URL base del API Gateway
  static const String baseUrl = 'https://api.capbox.site';

  // ==============================
  // CREDENCIALES OAUTH2 (APP MÓVIL - ACTUALIZADAS)
  // ==============================
  static String get oauthClientId =>
      dotenv.env['OAUTH_CLIENT_ID'] ?? 'capbox-mobile-app';
  static String get oauthClientSecret =>
      dotenv.env['OAUTH_CLIENT_SECRET'] ?? 'capbox-secret-key-2024';

  // ==============================
  // ENDPOINTS DE AUTENTICACIÓN (IDENTITY)
  // ==============================
  static const String register = '/identity/v1/auth/register';
  static const String oauthToken =
      '/identity/v1/oauth/token'; // ✅ CORRECTO: Según documentación oficial del backend
  static const String oauthRefresh =
      '/identity/v1/oauth/token/refresh'; // CORREGIDO: /refresh
  static const String userProfile = '/identity/v1/usuarios/me'; // ✅ CORRECTO
  static const String userGymKey =
      '/identity/v1/usuarios/gimnasio/clave'; // ✅ CORRECTO
  static const String adminGymKey =
      '/identity/v1/usuarios/gimnasio/clave'; // ✅ CORRECTO
  static const String forgotPassword = '/identity/v1/auth/forgot-password';
  static const String resetPassword = '/identity/v1/auth/reset-password';
  static const String logout = '/identity/v1/auth/logout';
  static const String confirmEmail = '/identity/v1/auth/confirm-email';

  // ==============================
  // ENDPOINTS DE GIMNASIOS (IDENTITY)
  // ==============================
  static const String linkGym =
      '/identity/v1/gimnasios/vincular'; // CORREGIDO: Según backend
  static const String gymMembers =
      '/identity/v1/gimnasios/miembros'; // CORREGIDO: Según backend
  static String gymMembersByGym(String gymId) =>
      '/identity/v1/gimnasios/$gymId/miembros'; // CORREGIDO

  // ==============================
  // ENDPOINTS DE SOLICITUDES (IDENTITY)
  // ==============================
  static const String pendingRequests = '/identity/v1/requests/pending';
  static String approveAthlete(String athleteId) =>
      '/identity/v1/atletas/$athleteId/aprobar';
  static String debugSolicitud(String athleteId) =>
      '/identity/v1/atletas/debug/solicitud/$athleteId';
  static String limpiarSolicitudConflictiva(String athleteId) =>
      '/identity/v1/atletas/$athleteId/limpiar-solicitud';

  // ==============================
  // ENDPOINTS DE USUARIOS (IDENTITY)
  // ==============================
  static const String userSync =
      '/identity/v1/usuarios/sync'; // NUEVO: Según backend

  // ==============================
  // ENDPOINTS DE PLANIFICACIÓN
  // ==============================
  static const String exercises = '/v1/planning/exercises';
  static const String routines = '/v1/planning/routines';
  static String routineById(String id) => '/v1/planning/routines/$id';
  static String routinesByLevel(String nivel) =>
      '/v1/planning/routines?nivel=$nivel';
  static const String assignments = '/v1/planning/assignments';
  static const String myAssignments = '/v1/planning/assignments/me';
  static String assignmentsByAthlete(String atletaId) =>
      '/v1/planning/assignments/athlete/$atletaId';

  // ==============================
  // ENDPOINTS DE PERFORMANCE
  // ==============================
  static const String sessions = '/v1/performance/sessions';
  static const String mySessions = '/v1/performance/sessions/me';
  static String sessionsByAthlete(String atletaId) =>
      '/v1/performance/sessions/athlete/$atletaId';
  static const String tests = '/v1/performance/tests';
  static String testsByAthlete(String atletaId) =>
      '/v1/performance/tests/athlete/$atletaId';
  static const String combatEvents = '/v1/performance/combat-events';
  static String combatEventsByAthlete(String atletaId) =>
      '/v1/performance/combat-events/athlete/$atletaId';
  static const String attendance = '/v1/performance/attendance';

  // ==============================
  // URLS BASE (para compatibilidad)
  // ==============================
  static String get identidadBaseUrl => baseUrl;
  static String get planificacionBaseUrl => baseUrl;
  static String get performanceBaseUrl => baseUrl;

  // Helper methods
  static String getIdentidadUrl(String endpoint) => baseUrl + endpoint;
  static String getPlanificacionUrl(String endpoint) => baseUrl + endpoint;
  static String getPerformanceUrl(String endpoint) => baseUrl + endpoint;

  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
