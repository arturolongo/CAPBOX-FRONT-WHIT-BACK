/// DTO para la respuesta de clave del gimnasio
class GymKeyResponse {
  final String claveGym;

  GymKeyResponse({required this.claveGym});

  factory GymKeyResponse.fromJson(Map<String, dynamic> json) {
    return GymKeyResponse(claveGym: json['claveGym'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'claveGym': claveGym};
  }
}
