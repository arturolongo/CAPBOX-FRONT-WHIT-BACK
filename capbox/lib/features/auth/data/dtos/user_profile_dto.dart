class UserProfileDto {
  final String id;
  final String email;
  final String nombre;
  final String rol;
  final GimnasioDto? gimnasio;
  final PerfilAtletaDto? perfilAtleta;

  UserProfileDto({
    required this.id,
    required this.email,
    required this.nombre,
    required this.rol,
    this.gimnasio,
    this.perfilAtleta,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      id: json['id'],
      email: json['email'],
      nombre: json['nombre'],
      rol: json['rol'],
      gimnasio:
          json['gimnasio'] != null
              ? GimnasioDto.fromJson(json['gimnasio'])
              : null,
      perfilAtleta:
          json['perfilAtleta'] != null
              ? PerfilAtletaDto.fromJson(json['perfilAtleta'])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'nombre': nombre,
    'rol': rol,
    'gimnasio': gimnasio?.toJson(),
    'perfilAtleta': perfilAtleta?.toJson(),
  };
}

class GimnasioDto {
  final String id;
  final String nombre;

  GimnasioDto({required this.id, required this.nombre});

  factory GimnasioDto.fromJson(Map<String, dynamic> json) {
    return GimnasioDto(id: json['id'], nombre: json['nombre']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'nombre': nombre};
}

class PerfilAtletaDto {
  final String nivel;
  final double alturaCm;
  final double pesoKg;
  final String guardia;
  final String? alergias;
  final String? contactoEmergenciaNombre;
  final String? contactoEmergenciaTelefono;

  PerfilAtletaDto({
    required this.nivel,
    required this.alturaCm,
    required this.pesoKg,
    required this.guardia,
    this.alergias,
    this.contactoEmergenciaNombre,
    this.contactoEmergenciaTelefono,
  });

  factory PerfilAtletaDto.fromJson(Map<String, dynamic> json) {
    return PerfilAtletaDto(
      nivel: json['nivel'],
      alturaCm: json['alturaCm'].toDouble(),
      pesoKg: json['pesoKg'].toDouble(),
      guardia: json['guardia'],
      alergias: json['alergias'],
      contactoEmergenciaNombre: json['contactoEmergenciaNombre'],
      contactoEmergenciaTelefono: json['contactoEmergenciaTelefono'],
    );
  }

  Map<String, dynamic> toJson() => {
    'nivel': nivel,
    'alturaCm': alturaCm,
    'pesoKg': pesoKg,
    'guardia': guardia,
    'alergias': alergias,
    'contactoEmergenciaNombre': contactoEmergenciaNombre,
    'contactoEmergenciaTelefono': contactoEmergenciaTelefono,
  };
}
