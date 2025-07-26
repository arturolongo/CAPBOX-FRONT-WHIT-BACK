class RoutineListDto {
  final String id;
  final String nombre;
  final String nivel;
  final int cantidadEjercicios;
  final int duracionEstimadaMinutos;

  RoutineListDto({
    required this.id,
    required this.nombre,
    required this.nivel,
    required this.cantidadEjercicios,
    required this.duracionEstimadaMinutos,
  });

  factory RoutineListDto.fromJson(Map<String, dynamic> json) {
    return RoutineListDto(
      id: json['id'],
      nombre: json['nombre'],
      nivel: json['nivel'],
      cantidadEjercicios: json['cantidadEjercicios'],
      duracionEstimadaMinutos: json['duracionEstimadaMinutos'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'nivel': nivel,
    'cantidadEjercicios': cantidadEjercicios,
    'duracionEstimadaMinutos': duracionEstimadaMinutos,
  };
}

class RoutineDetailDto {
  final String id;
  final String nombre;
  final String nivel;
  final List<EjercicioDto> ejercicios;

  RoutineDetailDto({
    required this.id,
    required this.nombre,
    required this.nivel,
    required this.ejercicios,
  });

  factory RoutineDetailDto.fromJson(Map<String, dynamic> json) {
    return RoutineDetailDto(
      id: json['id'],
      nombre: json['nombre'],
      nivel: json['nivel'],
      ejercicios:
          (json['ejercicios'] as List)
              .map((e) => EjercicioDto.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'nivel': nivel,
    'ejercicios': ejercicios.map((e) => e.toJson()).toList(),
  };
}

class EjercicioDto {
  final String id;
  final String nombre;
  final String setsReps;

  EjercicioDto({
    required this.id,
    required this.nombre,
    required this.setsReps,
  });

  factory EjercicioDto.fromJson(Map<String, dynamic> json) {
    return EjercicioDto(
      id: json['id'],
      nombre: json['nombre'],
      setsReps: json['setsReps'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'setsReps': setsReps,
  };
}

class AssignmentDto {
  final String idAsignacion;
  final String tipoPlan;
  final String idPlan;
  final String nombrePlan;
  final String idAsignador;
  final String estado;
  final DateTime fechaAsignacion;

  AssignmentDto({
    required this.idAsignacion,
    required this.tipoPlan,
    required this.idPlan,
    required this.nombrePlan,
    required this.idAsignador,
    required this.estado,
    required this.fechaAsignacion,
  });

  factory AssignmentDto.fromJson(Map<String, dynamic> json) {
    return AssignmentDto(
      idAsignacion: json['idAsignacion'],
      tipoPlan: json['tipoPlan'],
      idPlan: json['idPlan'],
      nombrePlan: json['nombrePlan'],
      idAsignador: json['idAsignador'],
      estado: json['estado'],
      fechaAsignacion: DateTime.parse(json['fechaAsignacion']),
    );
  }

  Map<String, dynamic> toJson() => {
    'idAsignacion': idAsignacion,
    'tipoPlan': tipoPlan,
    'idPlan': idPlan,
    'nombrePlan': nombrePlan,
    'idAsignador': idAsignador,
    'estado': estado,
    'fechaAsignacion': fechaAsignacion.toIso8601String(),
  };
}
