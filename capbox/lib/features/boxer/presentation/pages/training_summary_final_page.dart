import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/boxer_navbar.dart';
import 'training_session_page.dart';
import '../../../../core/services/aws_api_service.dart';
import '../../data/services/performance_service.dart';

class TrainingSummaryFinalPage extends StatefulWidget {
  final Map<String, dynamic> sessionData;

  const TrainingSummaryFinalPage({super.key, required this.sessionData});

  @override
  State<TrainingSummaryFinalPage> createState() =>
      _TrainingSummaryFinalPageState();
}

class _TrainingSummaryFinalPageState extends State<TrainingSummaryFinalPage> {
  bool isSaving = false;
  bool isSaved = false;

  late Map<TrainingSection, int> sectionTimes;
  late Map<TrainingSection, int> sectionTargets;
  late int totalTimeUsed;
  late int totalTarget;
  late int exerciseCount;
  late DateTime sessionStartTime;

  @override
  void initState() {
    super.initState();
    _extractSessionData();
  }

  void _extractSessionData() {
    sectionTimes = Map<TrainingSection, int>.from(
      widget.sessionData['sectionTimes'] ?? {},
    );
    sectionTargets = Map<TrainingSection, int>.from(
      widget.sessionData['sectionTargets'] ?? {},
    );
    totalTimeUsed = widget.sessionData['totalTimeUsed'] ?? 0;
    totalTarget = widget.sessionData['totalTarget'] ?? 0;
    exerciseCount = widget.sessionData['exerciseCount'] ?? 0;
    sessionStartTime = widget.sessionData['sessionStartTime'] ?? DateTime.now();
  }

  Future<void> _saveTrainingSession() async {
    setState(() {
      isSaving = true;
    });

    try {
      print('💾 [TrainingSummary] Guardando sesión de entrenamiento...');

      // Usar el nuevo PerformanceService con estructura backend
      final apiService = context.read<AWSApiService>();
      final performanceService = PerformanceService(apiService);

      // Convertir sectionTimes a SeccionEntrenamientoDto
      final secciones =
          sectionTimes.entries.map((entry) {
            String categoria;
            switch (entry.key) {
              case TrainingSection.calentamiento:
                categoria = 'calentamiento';
                break;
              case TrainingSection.resistencia:
                categoria = 'resistencia';
                break;
              case TrainingSection.tecnica:
                categoria = 'tecnica';
                break;
              default:
                categoria = 'tecnica';
            }

            return SeccionEntrenamientoDto(
              categoria: categoria,
              tiempoUsadoSegundos: entry.value,
              tiempoObjetivoSegundos: sectionTargets[entry.key] ?? 0,
              ejerciciosCompletados: 4, // Promedio por sección
            );
          }).toList();

      // TODO: En el futuro, obtener assignmentId real del contexto
      // Por ahora usar un UUID temporal hasta que se integre con asignaciones
      final assignmentId = 'assignment-temporal-uuid';

      final resultado = await performanceService.registerTrainingSession(
        assignmentId: assignmentId,
        fechaInicio: sessionStartTime,
        fechaFin: DateTime.now(),
        duracionTotalSegundos: totalTimeUsed,
        tiempoObjetivoSegundos: totalTarget,
        ejerciciosCompletados: exerciseCount,
        secciones: secciones,
      );

      setState(() {
        isSaved = true;
        isSaving = false;
      });

      print('✅ [TrainingSummary] Sesión guardada exitosamente');
      print(
        '🏆 [TrainingSummary] Racha actualizada: ${resultado.rachaActualizada}',
      );

      // Mostrar mensaje de éxito con la racha
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sesión guardada! Racha: ${resultado.rachaActualizada} días',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ [TrainingSummary] Error guardando sesión: $e');
      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error guardando sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const BoxerNavBar(currentIndex: 1),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/fondo.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.6)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Header
                  const Text(
                    '🏆 ENTRENAMIENTO COMPLETADO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¡Excelente trabajo!',
                    style: TextStyle(color: Colors.green[300], fontSize: 16),
                  ),

                  const SizedBox(height: 32),

                  // Tiempo total
                  _buildTotalTimeCard(),

                  const SizedBox(height: 24),

                  // Estadísticas por sección
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tiempo por sección',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Expanded(
                          child: ListView(
                            children: [
                              _buildSectionCard(
                                TrainingSection.calentamiento,
                                'Calentamiento',
                                'assets/icons/calentamiento.png',
                              ),
                              const SizedBox(height: 12),
                              _buildSectionCard(
                                TrainingSection.resistencia,
                                'Resistencia',
                                'assets/icons/resistencia.png',
                              ),
                              const SizedBox(height: 12),
                              _buildSectionCard(
                                TrainingSection.tecnica,
                                'Técnica',
                                'assets/icons/tecnica.png',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botones de acción
                  if (!isSaved)
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isSaving ? null : _saveTrainingSession,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                isSaving
                                    ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          'Guardando...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    )
                                    : const Text(
                                      '💾 Guardar entrenamiento',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            border: Border.all(color: Colors.green),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                '✅ Entrenamiento guardado',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                  // Botón volver
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => context.go('/boxer-home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Volver al inicio',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalTimeCard() {
    final isUnderTarget = totalTimeUsed <= totalTarget;
    final timeDifference = (totalTimeUsed - totalTarget).abs();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnderTarget ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Tiempo total',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDuration(totalTimeUsed),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Meta: ${_formatDuration(totalTarget)}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUnderTarget ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isUnderTarget
                      ? '${_formatDuration(timeDifference)} bajo'
                      : '${_formatDuration(timeDifference)} sobre',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                '$exerciseCount ejercicios completados',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    TrainingSection section,
    String title,
    String iconPath,
  ) {
    final timeUsed = sectionTimes[section] ?? 0;
    final target = sectionTargets[section] ?? 0;
    final isUnderTarget = timeUsed <= target;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isUnderTarget
                  ? Colors.green.withOpacity(0.5)
                  : Colors.orange.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Image.asset(iconPath, height: 24, width: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Meta: ${_formatDuration(target)}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDuration(timeUsed),
                style: TextStyle(
                  color: isUnderTarget ? Colors.green : Colors.orange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                isUnderTarget ? Icons.check_circle : Icons.access_time,
                color: isUnderTarget ? Colors.green : Colors.orange,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }
}
