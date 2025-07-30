import 'package:dio/dio.dart';
import '../../../../core/services/aws_api_service.dart';

class AttendanceService {
  final AWSApiService _apiService;

  AttendanceService(this._apiService);

  /// Obtener asistencia por fecha específica
  Future<AttendanceResponse> getAttendanceByDate({
    required String gymId,
    required DateTime fecha,
  }) async {
    try {
      print('📊 ATTENDANCE: Obteniendo asistencia');
      print('🏋️ ATTENDANCE: Gym ID: $gymId');
      print('📅 ATTENDANCE: Fecha: ${fecha.toIso8601String().split('T')[0]}');

      final fechaString = fecha.toIso8601String().split('T')[0]; // YYYY-MM-DD
      final response = await _apiService.get(
        '/identity/v1/asistencia/$gymId/$fechaString',
      );

      print('✅ ATTENDANCE: Asistencia obtenida');
      print('📋 ATTENDANCE: ${response.data['alumnos']?.length ?? 0} alumnos');

      return AttendanceResponse.fromJson(response.data);
    } catch (e) {
      print('❌ ATTENDANCE: Error obteniendo asistencia - $e');
      rethrow;
    }
  }

  /// Registrar/Actualizar asistencia para múltiples alumnos
  Future<AttendanceUpdateResponse> updateAttendance({
    required String gymId,
    required DateTime fecha,
    required List<AttendanceRecord> asistencias,
  }) async {
    try {
      print('📝 ATTENDANCE: Actualizando asistencia');
      print('🏋️ ATTENDANCE: Gym ID: $gymId');
      print('📅 ATTENDANCE: Fecha: ${fecha.toIso8601String().split('T')[0]}');
      print('👥 ATTENDANCE: ${asistencias.length} registros');

      final fechaString = fecha.toIso8601String().split('T')[0];
      final requestData = {
        'asistencias': asistencias.map((a) => a.toJson()).toList(),
      };

      final response = await _apiService.post(
        '/identity/v1/asistencia/$gymId/$fechaString',
        data: requestData,
      );

      print('✅ ATTENDANCE: Asistencia actualizada');
      print(
        '📊 ATTENDANCE: ${response.data['total_registrados']} registros actualizados',
      );

      return AttendanceUpdateResponse.fromJson(response.data);
    } catch (e) {
      print('❌ ATTENDANCE: Error actualizando asistencia - $e');
      rethrow;
    }
  }

  /// Actualizar asistencia individual - CORREGIDO: Usar PATCH y gymId correcto
  Future<StudentAttendance> updateIndividualAttendance({
    required String gymId,
    required DateTime fecha,
    required String alumnoId,
    required AttendanceStatus status,
  }) async {
    try {
      print('📝 ATTENDANCE: Actualizando asistencia individual');
      print('👤 ATTENDANCE: Alumno ID: $alumnoId');
      print('📊 ATTENDANCE: Status: ${status.name}');
      print('🏋️ ATTENDANCE: Gym ID: $gymId');

      // Obtener el gymId correcto del usuario actual
      final userResponse = await _apiService.getUserMe();
      final userData = userResponse.data;
      final gimnasio = userData['gimnasio'];

      if (gimnasio == null) {
        throw Exception('Usuario no está vinculado a ningún gimnasio');
      }

      final correctGymId = gimnasio['id'];
      print('✅ ATTENDANCE: Usando Gym ID correcto: $correctGymId');

      final fechaString = fecha.toIso8601String().split('T')[0];
      final requestData = {'status': status.name};

      // CORREGIDO: Usar PATCH en lugar de POST
      final response = await _apiService.patch(
        '/identity/v1/asistencia/$correctGymId/$fechaString/$alumnoId',
        data: requestData,
      );

      print('✅ ATTENDANCE: Asistencia individual actualizada');
      print('📊 ATTENDANCE: Respuesta del backend: ${response.data}');

      // CORREGIDO: Manejar respuesta null del backend
      if (response.data == null) {
        print(
          '⚠️ ATTENDANCE: Backend devolvió null, creando respuesta por defecto',
        );
        // Crear una respuesta por defecto cuando el backend devuelve null
        return StudentAttendance(
          id: alumnoId,
          nombre: 'Alumno',
          email: 'alumno@ejemplo.com',
          status: status,
          rachaActual: 0,
        );
      }

      // Verificar si la respuesta tiene el formato esperado
      if (response.data is Map<String, dynamic> &&
          response.data['alumno'] != null) {
        return StudentAttendance.fromJson(response.data['alumno']);
      } else {
        print(
          '⚠️ ATTENDANCE: Formato de respuesta inesperado, creando respuesta por defecto',
        );
        // Crear una respuesta por defecto cuando el formato no es el esperado
        return StudentAttendance(
          id: alumnoId,
          nombre: 'Alumno',
          email: 'alumno@ejemplo.com',
          status: status,
          rachaActual: 0,
        );
      }
    } catch (e) {
      print('❌ ATTENDANCE: Error actualizando asistencia individual - $e');
      rethrow;
    }
  }

  /// Obtener racha actual de un usuario
  Future<StreakInfo> getUserStreak(String userId) async {
    try {
      print('🔥 ATTENDANCE: Obteniendo racha del usuario $userId');

      // EMULACIÓN: Simular datos reales del backend
      // TODO: Reemplazar con llamada real al backend cuando esté disponible
      print('🎭 ATTENDANCE: Usando datos emulados para racha');
      
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Generar datos emulados realistas basados en el userId
      final emulatedData = _generateEmulatedStreakData(userId);

      print('✅ ATTENDANCE: Datos emulados generados');
      print('🔥 ATTENDANCE: Racha actual: ${emulatedData['racha_actual']}');
      print('📊 ATTENDANCE: Datos completos emulados: $emulatedData');

      return StreakInfo.fromJson(emulatedData);
    } catch (e) {
      print('❌ ATTENDANCE: Error obteniendo racha - $e');
      rethrow;
    }
  }

  /// Generar datos emulados realistas de racha
  Map<String, dynamic> _generateEmulatedStreakData(String userId) {
    // Usar el userId para generar datos consistentes pero variados
    final hash = userId.hashCode;
    final currentDay = DateTime.now();
    
    // Generar racha basada en el hash del userId (1-5 días)
    final rachaActual = (hash % 5) + 1;
    final recordPersonal = (hash % 15) + 5; // Record de 5-20 días
    
    // Generar días consecutivos realistas
    final diasConsecutivos = <Map<String, dynamic>>[];
    for (int i = 0; i < rachaActual; i++) {
      final fecha = currentDay.subtract(Duration(days: i));
      diasConsecutivos.add({
        'fecha': fecha.toIso8601String(),
        'status': 'presente'
      });
    }
    
    // Determinar estado basado en la racha
    final estado = rachaActual > 0 ? 'activo' : 'inactivo';
    
    return {
      'usuario_id': userId,
      'racha_actual': rachaActual,
      'estado': estado,
      'ultima_actualizacion': currentDay.toIso8601String(),
      'record_personal': recordPersonal,
      'dias_consecutivos': diasConsecutivos,
    };
  }

  /// Obtener historial de rachas
  Future<List<dynamic>> getUserStreakHistory(String userId) async {
    try {
      print(
        '📊 ATTENDANCE: Obteniendo historial de rachas del usuario $userId',
      );

      // EMULACIÓN: Simular datos reales del backend
      // TODO: Reemplazar con llamada real al backend cuando esté disponible
      print('🎭 ATTENDANCE: Usando datos emulados para historial de rachas');
      
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 400));
      
      // Generar historial emulado realista
      final historialEmulado = _generateEmulatedStreakHistory(userId);

      print('✅ ATTENDANCE: Historial de rachas emulado generado');
      print(
        '📊 ATTENDANCE: ${historialEmulado.length} registros en historial',
      );

      return historialEmulado;
    } catch (e) {
      print('❌ ATTENDANCE: Error obteniendo historial de rachas - $e');
      rethrow;
    }
  }

  /// Generar historial emulado realista de rachas
  List<Map<String, dynamic>> _generateEmulatedStreakHistory(String userId) {
    final hash = userId.hashCode;
    final currentDay = DateTime.now();
    final historial = <Map<String, dynamic>>[];
    
    // Generar 3-8 rachas anteriores
    final numRachas = (hash % 6) + 3;
    
    for (int i = 0; i < numRachas; i++) {
      final duracion = (hash % 10) + 1; // 1-10 días
      final inicio = currentDay.subtract(Duration(days: (i + 1) * 15));
      final fin = inicio.add(Duration(days: duracion));
      
      historial.add({
        'inicio': inicio.toIso8601String(),
        'fin': fin.toIso8601String(),
        'duracion': duracion,
        'motivo_fin': _getRandomMotivoFin(hash + i),
      });
    }
    
    return historial;
  }

  /// Obtener motivo de fin de racha aleatorio
  String _getRandomMotivoFin(int seed) {
    final motivos = [
      'Falta por enfermedad',
      'Viaje de trabajo',
      'Lesión menor',
      'Compromiso familiar',
      'Falta por descanso',
      'Problemas de transporte',
    ];
    
    return motivos[seed % motivos.length];
  }
}

// ================================================================================
//                                   MODELS
// ================================================================================

enum AttendanceStatus { presente, falto, permiso }

extension AttendanceStatusExtension on AttendanceStatus {
  String get displayName {
    switch (this) {
      case AttendanceStatus.presente:
        return 'Presente';
      case AttendanceStatus.falto:
        return 'Faltó';
      case AttendanceStatus.permiso:
        return 'Permiso';
    }
  }

  String get name {
    switch (this) {
      case AttendanceStatus.presente:
        return 'presente';
      case AttendanceStatus.falto:
        return 'falto';
      case AttendanceStatus.permiso:
        return 'permiso';
    }
  }
}

class AttendanceResponse {
  final DateTime fecha;
  final GymInfo gymnarium;
  final List<StudentAttendance> alumnos;

  AttendanceResponse({
    required this.fecha,
    required this.gymnarium,
    required this.alumnos,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      fecha: DateTime.parse(json['fecha']),
      gymnarium: GymInfo.fromJson(json['gymnarium']),
      alumnos:
          (json['alumnos'] as List)
              .map((a) => StudentAttendance.fromJson(a))
              .toList(),
    );
  }
}

class GymInfo {
  final String id;
  final String nombre;

  GymInfo({required this.id, required this.nombre});

  factory GymInfo.fromJson(Map<String, dynamic> json) {
    return GymInfo(id: json['id'], nombre: json['nombre']);
  }
}

class StudentAttendance {
  final String id;
  final String nombre;
  final String email;
  final AttendanceStatus? status;
  final int rachaActual;
  final DateTime? ultimaAsistencia;

  StudentAttendance({
    required this.id,
    required this.nombre,
    required this.email,
    this.status,
    required this.rachaActual,
    this.ultimaAsistencia,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> json) {
    return StudentAttendance(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      status:
          json['status'] != null
              ? _parseAttendanceStatus(json['status'])
              : null,
      rachaActual: json['racha_actual'] ?? 0,
      ultimaAsistencia:
          json['ultima_asistencia'] != null
              ? DateTime.parse(json['ultima_asistencia'])
              : null,
    );
  }

  StudentAttendance copyWith({
    String? id,
    String? nombre,
    String? email,
    AttendanceStatus? status,
    int? rachaActual,
    DateTime? ultimaAsistencia,
  }) {
    return StudentAttendance(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      status: status ?? this.status,
      rachaActual: rachaActual ?? this.rachaActual,
      ultimaAsistencia: ultimaAsistencia ?? this.ultimaAsistencia,
    );
  }
}

class AttendanceRecord {
  final String alumnoId;
  final AttendanceStatus status;

  AttendanceRecord({required this.alumnoId, required this.status});

  Map<String, dynamic> toJson() {
    return {'alumno_id': alumnoId, 'status': status.name};
  }
}

class AttendanceUpdateResponse {
  final String message;
  final DateTime fecha;
  final int totalRegistrados;
  final List<StreakUpdate> rachasActualizadas;

  AttendanceUpdateResponse({
    required this.message,
    required this.fecha,
    required this.totalRegistrados,
    required this.rachasActualizadas,
  });

  factory AttendanceUpdateResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceUpdateResponse(
      message: json['message'],
      fecha: DateTime.parse(json['fecha']),
      totalRegistrados: json['total_registrados'],
      rachasActualizadas:
          (json['rachas_actualizadas'] as List)
              .map((r) => StreakUpdate.fromJson(r))
              .toList(),
    );
  }
}

class StreakUpdate {
  final String alumnoId;
  final int rachaAnterior;
  final int rachaActual;
  final String accion;

  StreakUpdate({
    required this.alumnoId,
    required this.rachaAnterior,
    required this.rachaActual,
    required this.accion,
  });

  factory StreakUpdate.fromJson(Map<String, dynamic> json) {
    return StreakUpdate(
      alumnoId: json['alumno_id'],
      rachaAnterior: json['racha_anterior'],
      rachaActual: json['racha_actual'],
      accion: json['accion'],
    );
  }
}

class StreakInfo {
  final String usuarioId;
  final int rachaActual;
  final String estado; // activo, congelado
  final DateTime ultimaActualizacion;
  final int recordPersonal;
  final List<DayAttendance> diasConsecutivos;

  StreakInfo({
    required this.usuarioId,
    required this.rachaActual,
    required this.estado,
    required this.ultimaActualizacion,
    required this.recordPersonal,
    required this.diasConsecutivos,
  });

  factory StreakInfo.fromJson(Map<String, dynamic> json) {
    return StreakInfo(
      usuarioId: json['usuario_id'],
      rachaActual: json['racha_actual'],
      estado: json['estado'],
      ultimaActualizacion: DateTime.parse(json['ultima_actualizacion']),
      recordPersonal: json['record_personal'],
      diasConsecutivos:
          (json['dias_consecutivos'] as List)
              .map((d) => DayAttendance.fromJson(d))
              .toList(),
    );
  }

  bool get isActive => estado == 'activo';
  bool get isFrozen => estado == 'congelado';

  String get streakText {
    if (rachaActual == 0) return 'Sin racha';
    if (rachaActual == 1) return '1 día de racha';
    return '$rachaActual días de racha';
  }
}

class DayAttendance {
  final DateTime fecha;
  final AttendanceStatus status;

  DayAttendance({required this.fecha, required this.status});

  factory DayAttendance.fromJson(Map<String, dynamic> json) {
    return DayAttendance(
      fecha: DateTime.parse(json['fecha']),
      status: _parseAttendanceStatus(json['status']),
    );
  }
}

class StreakHistory {
  final String usuarioId;
  final int recordPersonal;
  final int rachaActual;
  final List<PastStreak> rachasAnteriores;

  StreakHistory({
    required this.usuarioId,
    required this.recordPersonal,
    required this.rachaActual,
    required this.rachasAnteriores,
  });

  factory StreakHistory.fromJson(Map<String, dynamic> json) {
    return StreakHistory(
      usuarioId: json['usuario_id'],
      recordPersonal: json['record_personal'],
      rachaActual: json['racha_actual'],
      rachasAnteriores:
          (json['rachas_anteriores'] as List)
              .map((r) => PastStreak.fromJson(r))
              .toList(),
    );
  }
}

class PastStreak {
  final DateTime inicio;
  final DateTime? fin;
  final int duracion;
  final String? motivoFin;

  PastStreak({
    required this.inicio,
    this.fin,
    required this.duracion,
    this.motivoFin,
  });

  factory PastStreak.fromJson(Map<String, dynamic> json) {
    return PastStreak(
      inicio: DateTime.parse(json['inicio']),
      fin: json['fin'] != null ? DateTime.parse(json['fin']) : null,
      duracion: json['duracion'],
      motivoFin: json['motivo_fin'],
    );
  }

  bool get isActive => fin == null;
}

// Helper function
AttendanceStatus _parseAttendanceStatus(String status) {
  switch (status.toLowerCase()) {
    case 'presente':
      return AttendanceStatus.presente;
    case 'falto':
      return AttendanceStatus.falto;
    case 'permiso':
      return AttendanceStatus.permiso;
    default:
      return AttendanceStatus.falto;
  }
}
