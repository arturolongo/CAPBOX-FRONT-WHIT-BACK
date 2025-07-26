enum UserRole { athlete, coach, admin }

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;
  final String token; // Para autenticación JWT

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.token,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    DateTime? createdAt,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      token: token ?? this.token,
    );
  }
}
