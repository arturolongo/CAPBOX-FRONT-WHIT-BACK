/// DTO para confirmación de email
class ConfirmEmailRequestDto {
  final String token;

  ConfirmEmailRequestDto({required this.token});

  Map<String, dynamic> toJson() => {'token': token};
}

class ConfirmEmailResponseDto {
  final String message;

  ConfirmEmailResponseDto({required this.message});

  factory ConfirmEmailResponseDto.fromJson(Map<String, dynamic> json) {
    return ConfirmEmailResponseDto(
      message: json['message'] ?? 'Email confirmado exitosamente',
    );
  }
}
