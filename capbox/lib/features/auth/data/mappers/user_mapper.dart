import '../../domain/entities/user.dart';
import '../dtos/user_profile_dto.dart';
import '../dtos/oauth_token_response_dto.dart';

class UserMapper {
  /// Crear User desde UserProfileDto (respuesta de /users/me)
  static User fromUserProfile(UserProfileDto dto, String token) {
    return User(
      id: dto.id,
      email: dto.email,
      name: dto.nombre, // Backend usa 'nombre'
      role: _parseRole(dto.rol), // Backend usa 'rol'
      createdAt: DateTime.now(), // No viene en la respuesta, usar fecha actual
      token: token,
    );
  }

  /// Crear User temporal solo con token (después del OAuth)
  static User fromTokenResponse(OAuthTokenResponseDto dto) {
    return User(
      id: '', // Se llenará después de obtener el perfil
      email: '',
      name: '',
      role: UserRole.athlete, // Default, se actualizará después
      createdAt: DateTime.now(),
      token: dto.accessToken,
    );
  }

  /// Compatibilidad hacia atrás - usar fromUserProfile preferiblemente
  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['nombre'] ?? json['name'] ?? '',
      role: _parseRole(json['rol'] ?? json['role'] ?? 'atleta'),
      createdAt: DateTime.now(),
      token: json['token'] ?? '',
    );
  }

  static UserRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'atleta':
      case 'athlete':
        return UserRole.athlete;
      case 'entrenador':
      case 'coach':
        return UserRole.coach;
      case 'administrador':
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.athlete; // Default a atleta en lugar de error
    }
  }

  static Map<String, dynamic> toJson(User user) {
    return {
      'id': user.id,
      'email': user.email,
      'nombre': user.name,
      'rol': _roleToSpanish(user.role),
    };
  }

  static String _roleToSpanish(UserRole role) {
    switch (role) {
      case UserRole.athlete:
        return 'Atleta';
      case UserRole.coach:
        return 'Entrenador';
      case UserRole.admin:
        return 'Administrador';
    }
  }
}
