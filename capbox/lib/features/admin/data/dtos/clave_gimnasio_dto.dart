/// DTO para la clave del gimnasio retornado por GET/PATCH /v1/profile/gym/key
class ClaveGimnasioDto {
  final String claveGym;

  const ClaveGimnasioDto({required this.claveGym});

  factory ClaveGimnasioDto.fromJson(Map<String, dynamic> json) {
    return ClaveGimnasioDto(claveGym: json['claveGym'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'claveGym': claveGym};
  }

  @override
  String toString() {
    return 'ClaveGimnasioDto{claveGym: $claveGym}';
  }
}
