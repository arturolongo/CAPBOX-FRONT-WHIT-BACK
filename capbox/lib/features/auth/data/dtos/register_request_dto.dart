class RegisterRequestDto {
  final String email;
  final String password;
  final String nombre;
  final String rol;
  final String claveGym;

  RegisterRequestDto({
    required this.email,
    required this.password,
    required this.nombre,
    required this.rol,
    required this.claveGym,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'nombre': nombre,
    'rol': rol,
    'claveGym': claveGym,
  };
}

class RegisterResponseDto {
  final int statusCode;
  final String message;
  final RegisterDataDto data;

  RegisterResponseDto({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) {
    return RegisterResponseDto(
      statusCode: json['statusCode'],
      message: json['message'],
      data: RegisterDataDto.fromJson(json['data']),
    );
  }
}

class RegisterDataDto {
  final String id;
  final String email;

  RegisterDataDto({required this.id, required this.email});

  factory RegisterDataDto.fromJson(Map<String, dynamic> json) {
    return RegisterDataDto(id: json['id'], email: json['email']);
  }
}
