/// DTO para el perfil de usuario completo retornado por POST /v1/gyms/link
class PerfilUsuarioDto {
  final String id;
  final String email;
  final String nombre;
  final String rol;
  final GimnasioDto? gimnasio;
  final Map<String, dynamic>? perfilAtleta;
  final DateTime? fechaCreacion;

  const PerfilUsuarioDto({
    required this.id,
    required this.email,
    required this.nombre,
    required this.rol,
    this.gimnasio,
    this.perfilAtleta,
    this.fechaCreacion,
  });

  factory PerfilUsuarioDto.fromJson(Map<String, dynamic> json) {
    return PerfilUsuarioDto(
      id: json['id'] as String,
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      rol: json['rol'] as String,
      gimnasio:
          json['gimnasio'] != null
              ? GimnasioDto.fromJson(json['gimnasio'] as Map<String, dynamic>)
              : null,
      perfilAtleta: json['perfilAtleta'] as Map<String, dynamic>?,
      fechaCreacion:
          json['fechaCreacion'] != null
              ? DateTime.parse(json['fechaCreacion'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'rol': rol,
      'gimnasio': gimnasio?.toJson(),
      'perfilAtleta': perfilAtleta,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'PerfilUsuarioDto{id: $id, email: $email, nombre: $nombre, rol: $rol, gimnasio: $gimnasio}';
  }
}

/// DTO para información del gimnasio
class GimnasioDto {
  final String id;
  final String nombre;
  final String? descripcion;
  final DateTime? fechaCreacion;

  const GimnasioDto({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.fechaCreacion,
  });

  factory GimnasioDto.fromJson(Map<String, dynamic> json) {
    return GimnasioDto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      fechaCreacion:
          json['fechaCreacion'] != null
              ? DateTime.parse(json['fechaCreacion'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'GimnasioDto{id: $id, nombre: $nombre, descripcion: $descripcion}';
  }
}
