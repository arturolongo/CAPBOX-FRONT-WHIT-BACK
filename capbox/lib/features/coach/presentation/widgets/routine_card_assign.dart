import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../data/dtos/routine_dto.dart';
import '../../data/services/assignment_service.dart';
import '../../../../core/services/aws_api_service.dart';

class RoutineCardAssign extends StatefulWidget {
  final RoutineDetailDto routine;
  final String nivel;
  final int index;
  final int? expandedIndex;
  final String selectedCategory;
  final Function(int) onExpand;
  final Function(String) onCategoryChange;

  const RoutineCardAssign({
    super.key,
    required this.routine,
    required this.nivel,
    required this.index,
    required this.expandedIndex,
    required this.selectedCategory,
    required this.onExpand,
    required this.onCategoryChange,
  });

  @override
  State<RoutineCardAssign> createState() => _RoutineCardAssignState();
}

class _RoutineCardAssignState extends State<RoutineCardAssign> {
  bool _isAssigning = false;

  Map<String, List<Map<String, dynamic>>> _getExercisesByCategory() {
    final Map<String, List<Map<String, dynamic>>> exercisesByCategory = {
      'calentamiento': [],
      'resistencia': [],
      'tecnica': [],
    };

    for (final ejercicio in widget.routine.ejercicios) {
      final categoria = ejercicio.categoria ?? 'tecnica';
      if (exercisesByCategory.containsKey(categoria)) {
        exercisesByCategory[categoria]!.add({
          'nombre': ejercicio.nombre,
          'duracion': _formatearDuracion(
            (ejercicio.duracionEstimadaSegundos ?? 0).toInt(),
          ),
          'setsReps': ejercicio.setsReps ?? '',
        });
      }
    }

    return exercisesByCategory;
  }

  String _formatearDuracion(int segundos) {
    if (segundos == 0) return '0 min';
    if (segundos < 60) return '${segundos}s';
    final minutos = segundos ~/ 60;
    final segundosRestantes = segundos % 60;
    if (segundosRestantes == 0) return '${minutos} min';
    return '${minutos}:${segundosRestantes.toString().padLeft(2, '0')}';
  }

  int _getTotalDurationMinutes() {
    int totalSegundos = 0;
    for (final ejercicio in widget.routine.ejercicios) {
      totalSegundos += (ejercicio.duracionEstimadaSegundos ?? 0).toInt();
    }
    return (totalSegundos / 60).round();
  }

  Future<List<String>> _getStudentsByLevel() async {
    try {
      print(
        '🔄 [RoutineCardAssign] Obteniendo estudiantes de nivel: ${widget.routine.nivel}',
      );

      final apiService = context.read<AWSApiService>();

      // Probar diferentes endpoints hasta encontrar el correcto
      print('🔍 [RoutineCardAssign] Probando endpoints disponibles...');

      // Usar el nivel de la rutina, no el nivel de la pantalla
      final routineLevel = widget.routine.nivel.toLowerCase();

      // Lista de posibles endpoints a probar
      final endpointsToTry = [
        '/planning/v1/coach/gym-students?nivel=$routineLevel',
        '/v1/coach/gym-students?nivel=$routineLevel',
        '/coach/gym-students?nivel=$routineLevel',
        '/planning/v1/coach/gym-students',
        '/v1/coach/gym-students',
        '/coach/gym-students',
      ];

      Response? response;
      String? workingEndpoint;

      for (final endpoint in endpointsToTry) {
        try {
          print('🔍 [RoutineCardAssign] Probando: $endpoint');

          // Agregar timestamp para evitar caché del navegador
          final timestampedEndpoint =
              endpoint.contains('?')
                  ? '$endpoint&_t=${DateTime.now().millisecondsSinceEpoch}'
                  : '$endpoint?_t=${DateTime.now().millisecondsSinceEpoch}';

          response = await apiService.get(timestampedEndpoint);

          if (response.statusCode == 200) {
            workingEndpoint =
                endpoint; // Mantener el endpoint original para logging
            print(
              '✅ [RoutineCardAssign] Endpoint funcional encontrado: $endpoint',
            );
            print(
              '📊 [RoutineCardAssign] Response status: ${response.statusCode}',
            );
            print(
              '📋 [RoutineCardAssign] Response data preview: ${response.data}',
            );
            break;
          }
        } catch (e) {
          print(
            '❌ [RoutineCardAssign] Endpoint $endpoint falló: ${e.runtimeType}',
          );
          print('🔍 [RoutineCardAssign] Error details: $e');
          continue;
        }
      }

      if (response == null || workingEndpoint == null) {
        throw Exception(
          'Ningún endpoint de estudiantes está disponible en el backend',
        );
      }

      if (response.statusCode == 200) {
        final studentsData = response.data as List<dynamic>;
        print(
          '📊 [RoutineCardAssign] Datos recibidos del backend: $studentsData',
        );

        // Filtrar por nivel si no está filtrado por el backend
        List<dynamic> filteredStudents;
        if (workingEndpoint.contains('nivel=')) {
          // El endpoint ya filtró por nivel
          filteredStudents = studentsData;
          print('✅ [RoutineCardAssign] Datos ya filtrados por backend');
        } else {
          // Filtrar manualmente en frontend
          filteredStudents =
              studentsData.where((student) {
                final studentLevel =
                    (student['level'] ?? student['nivel'] ?? '')
                        .toString()
                        .toLowerCase();
                final targetLevel = routineLevel; // Usar nivel de la rutina
                print(
                  '🔍 [RoutineCardAssign] Comparando: "$studentLevel" vs "$targetLevel"',
                );
                return studentLevel == targetLevel;
              }).toList();
          print('✅ [RoutineCardAssign] Filtrado manual completado');
        }

        // Convertir a lista de IDs
        final studentIds =
            filteredStudents
                .map((student) => student['id'].toString())
                .toList();

        print(
          '✅ [RoutineCardAssign] ${studentIds.length} estudiantes encontrados para nivel $routineLevel',
        );
        print('📋 [RoutineCardAssign] IDs de estudiantes: $studentIds');
        print('🎯 [RoutineCardAssign] Endpoint funcional: $workingEndpoint');
        return studentIds;
      } else {
        throw Exception('Error al obtener estudiantes del gimnasio');
      }
    } catch (e) {
      print('❌ [RoutineCardAssign] Error obteniendo estudiantes: $e');

      // Si falla la llamada al backend, lanzar error específico
      throw Exception(
        'Error al obtener estudiantes del gimnasio: ${e.toString()}',
      );
    }
  }

  Future<void> _assignRoutine() async {
    if (_isAssigning) return;

    setState(() {
      _isAssigning = true;
    });

    try {
      print(
        '🔄 [RoutineCardAssign] Iniciando asignación de rutina: ${widget.routine.nombre}',
      );
      print('📊 [RoutineCardAssign] Nivel objetivo: ${widget.nivel}');
      print('🆔 [RoutineCardAssign] ID de rutina: ${widget.routine.id}');

      // Obtener estudiantes del nivel
      print('🔍 [RoutineCardAssign] Llamando a _getStudentsByLevel...');
      final studentIds = await _getStudentsByLevel();
      print('📋 [RoutineCardAssign] Estudiantes obtenidos: $studentIds');

      if (studentIds.isEmpty) {
        throw Exception(
          'No hay estudiantes disponibles para el nivel ${widget.routine.nivel}',
        );
      }

      print(
        '📋 [RoutineCardAssign] Asignando a ${studentIds.length} estudiantes',
      );

      // Realizar asignación
      final apiService = context.read<AWSApiService>();
      final assignmentService = AssignmentService(apiService);

      final result = await assignmentService.assignRoutine(
        rutinaId: widget.routine.id,
        atletaIds: studentIds,
      );

      print(
        '✅ [RoutineCardAssign] Asignación exitosa: ${result.asignacionesCreadas} asignaciones creadas',
      );

      // Mostrar diálogo de éxito
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.grey.shade900,
                title: const Text(
                  '✅ Asignación Exitosa',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  'Rutina "${widget.routine.nombre}" asignada a ${result.asignacionesCreadas} estudiantes de nivel ${widget.routine.nivel}.',
                  style: const TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Aceptar',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      print('❌ [RoutineCardAssign] Error en asignación: $e');

      // Extraer mensaje específico del backend si es posible
      String errorMessage = 'Error al asignar rutina';
      if (e.toString().contains('DioException')) {
        // Intentar extraer el mensaje del backend
        if (e.toString().contains('400')) {
          errorMessage =
              'Error de validación: Revisa que los estudiantes y la rutina sean válidos';
        } else if (e.toString().contains('401')) {
          errorMessage = 'Error de autenticación: Verifica tu sesión';
        } else if (e.toString().contains('500')) {
          errorMessage = 'Error del servidor: Intenta más tarde';
        } else {
          errorMessage = 'Error de conexión: Verifica tu internet';
        }
      } else {
        errorMessage = e.toString();
      }

      // Mostrar diálogo de error
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.grey.shade900,
                title: const Text(
                  '❌ Error en Asignación',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Aceptar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAssigning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = widget.expandedIndex == widget.index;
    final exercisesByCategory = _getExercisesByCategory();
    final ejerciciosCategoria =
        exercisesByCategory[widget.selectedCategory] ?? [];
    final totalDuration = _getTotalDurationMinutes();

    return GestureDetector(
      onTap: () => widget.onExpand(isExpanded ? -1 : widget.index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.routine.nombre,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Text(
                  '${widget.routine.ejercicios.length} ejercicios',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey, size: 18),
                const SizedBox(width: 6),
                Text(
                  '$totalDuration min',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.routine.nivel,
              style: const TextStyle(color: Colors.red),
            ),

            if (isExpanded) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    ['calentamiento', 'resistencia', 'tecnica'].map((cat) {
                      final isSelected = widget.selectedCategory == cat;
                      final categoryExercises = exercisesByCategory[cat] ?? [];
                      return GestureDetector(
                        onTap: () => widget.onCategoryChange(cat),
                        child: Column(
                          children: [
                            Text(
                              cat[0].toUpperCase() + cat.substring(1),
                              style: TextStyle(
                                color: isSelected ? Colors.red : Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.red.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${categoryExercises.length}',
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.red : Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(8),
                child: Table(
                  border: const TableBorder(
                    horizontalInside: BorderSide(color: Colors.grey),
                    verticalInside: BorderSide(color: Colors.red),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1.5),
                    2: FlexColumnWidth(1.5),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.red)),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Center(
                            child: Text(
                              'Ejercicio',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Center(
                            child: Text(
                              'Duración',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Center(
                            child: Text(
                              'Sets/Reps',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (ejerciciosCategoria.isEmpty)
                      const TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text(
                                'Sin ejercicios en esta categoría',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(),
                          SizedBox(),
                        ],
                      )
                    else
                      ...ejerciciosCategoria.map<TableRow>((e) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Center(
                                child: Text(
                                  e['nombre'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Center(
                                child: Text(
                                  e['duracion'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Center(
                                child: Text(
                                  e['setsReps'] ?? '',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: _isAssigning ? null : _assignRoutine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAssigning ? Colors.grey : Colors.green,
                  ),
                  child:
                      _isAssigning
                          ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Asignando...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                          : const Text(
                            'Asignar',
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
