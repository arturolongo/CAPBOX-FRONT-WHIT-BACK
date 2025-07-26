/// DTO para representar un miembro del gimnasio
class GymMemberDto {
  final String id;
  final String name;
  final String email;
  final String role; // 'atleta', 'entrenador', 'administrador'
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime? joinedAt;
  final GymDto? gym;
  final AthleteProfileDto? athleteProfile;

  GymMemberDto({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.joinedAt,
    this.gym,
    this.athleteProfile,
  });

  factory GymMemberDto.fromJson(Map<String, dynamic> json) {
    return GymMemberDto(
      id: json['id']?.toString() ?? '',
      name: json['nombre'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['rol'] ?? json['role'] ?? 'atleta',
      status: json['estado'] ?? json['status'] ?? 'approved',
      joinedAt:
          json['fechaCreacion'] != null
              ? DateTime.tryParse(json['fechaCreacion'])
              : null,
      gym: json['gimnasio'] != null ? GymDto.fromJson(json['gimnasio']) : null,
      athleteProfile:
          json['perfilAtleta'] != null
              ? AthleteProfileDto.fromJson(json['perfilAtleta'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': name,
      'email': email,
      'rol': role,
      'estado': status,
      'fechaCreacion': joinedAt?.toIso8601String(),
      'gimnasio': gym?.toJson(),
      'perfilAtleta': athleteProfile?.toJson(),
    };
  }

  /// Crear instancia para datos mock/hardcodeados
  factory GymMemberDto.mock({
    required String id,
    required String name,
    String email = '',
    String role = 'atleta',
    String status = 'approved',
  }) {
    return GymMemberDto(
      id: id,
      name: name,
      email:
          email.isEmpty
              ? '${name.toLowerCase().replaceAll(' ', '.')}@example.com'
              : email,
      role: role,
      status: status,
      joinedAt: DateTime.now().subtract(Duration(days: 30)),
    );
  }

  /// Verificar si es atleta
  bool get isAthlete => role.toLowerCase() == 'atleta';

  /// Verificar si es entrenador
  bool get isCoach => role.toLowerCase() == 'entrenador';

  /// Verificar si es administrador
  bool get isAdmin => role.toLowerCase() == 'administrador';

  /// Verificar si está pendiente de aprobación
  bool get isPending => status.toLowerCase() == 'pending';

  /// Verificar si está aprobado
  bool get isApproved => status.toLowerCase() == 'approved';
}

/// DTO para información del gimnasio
class GymDto {
  final String id;
  final String name;
  final String location;

  GymDto({required this.id, required this.name, required this.location});

  factory GymDto.fromJson(Map<String, dynamic> json) {
    return GymDto(
      id: json['id']?.toString() ?? '',
      name: json['nombre'] ?? json['name'] ?? '',
      location: json['ubicacion'] ?? json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': name, 'ubicacion': location};
  }
}

/// DTO para perfil específico de atleta
class AthleteProfileDto {
  final String level; // 'principiante', 'intermedio', 'avanzado'
  final double? heightCm;
  final double? weightKg;
  final String? stance; // 'orthodox', 'southpaw', 'switcher'
  final int? wins;
  final int? losses;
  final int? fights;

  AthleteProfileDto({
    required this.level,
    this.heightCm,
    this.weightKg,
    this.stance,
    this.wins,
    this.losses,
    this.fights,
  });

  factory AthleteProfileDto.fromJson(Map<String, dynamic> json) {
    return AthleteProfileDto(
      level: json['nivel'] ?? json['level'] ?? 'principiante',
      heightCm: json['estaturaCm']?.toDouble() ?? json['heightCm']?.toDouble(),
      weightKg: json['pesoKg']?.toDouble() ?? json['weightKg']?.toDouble(),
      stance: json['guardia'] ?? json['stance'],
      wins: json['victorias'] ?? json['wins'],
      losses: json['derrotas'] ?? json['losses'],
      fights: json['peleas'] ?? json['fights'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nivel': level,
      'estaturaCm': heightCm,
      'pesoKg': weightKg,
      'guardia': stance,
      'victorias': wins,
      'derrotas': losses,
      'peleas': fights,
    };
  }

  /// Calcular edad aproximada (mock)
  int get approximateAge => 20; // Default para ejemplos

  /// Obtener descripción de stats
  String get statsDescription {
    final h = heightCm != null ? '${heightCm!.toInt()}cm' : '';
    final w = weightKg != null ? '${weightKg!.toInt()}kg' : '';
    final stats = [
      approximateAge.toString() + ' años',
      w,
      h,
    ].where((s) => s.isNotEmpty).join(' │ ');
    return stats;
  }
}
