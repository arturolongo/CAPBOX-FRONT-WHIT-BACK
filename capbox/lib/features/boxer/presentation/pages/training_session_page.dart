import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/boxer_navbar.dart';
import '../widgets/boxer_timer_header.dart';
import '../widgets/boxer_timer_table.dart';
import '../widgets/boxer_timer_actions.dart';

enum TrainingSection { calentamiento, resistencia, tecnica, completado }

class TrainingSessionPage extends StatefulWidget {
  final Map<String, dynamic>? routineData;

  const TrainingSessionPage({super.key, this.routineData});

  @override
  State<TrainingSessionPage> createState() => _TrainingSessionPageState();
}

class _TrainingSessionPageState extends State<TrainingSessionPage> {
  // Estado del entrenamiento
  TrainingSection currentSection = TrainingSection.calentamiento;
  int sectionIndex = 0;

  // Timer
  late int remainingSeconds;
  late int originalSectionTime;
  Timer? _timer;
  bool _isRunning = false;

  // Datos de sesiones
  late List<TrainingSectionData> sections;

  // Estadísticas de la sesión
  DateTime? sessionStartTime;
  Map<TrainingSection, int> sectionTimes = {};
  Map<TrainingSection, int> sectionTargets = {};

  @override
  void initState() {
    super.initState();
    _initializeTrainingData();
    _startSection(currentSection);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeTrainingData() {
    // Por ahora usar datos mock hasta que el Planning Service funcione
    sections = [
      TrainingSectionData(
        section: TrainingSection.calentamiento,
        title: 'SESIÓN DE CALENTAMIENTO',
        duration: 3 * 60, // 3 minutos para demo
        exercises: [
          {'name': 'Movimientos de hombro', 'count': '30'},
          {'name': 'Movimientos de cabeza', 'count': '30'},
          {'name': 'Estiramientos de brazos', 'count': '30'},
          {'name': 'Movimientos de pies', 'count': '1min'},
        ],
      ),
      TrainingSectionData(
        section: TrainingSection.resistencia,
        title: 'SESIÓN DE RESISTENCIA',
        duration: 3 * 60, // 3 minutos para demo
        exercises: [
          {'name': 'Burpees', 'count': '50'},
          {'name': 'Flexiones de pecho', 'count': '50'},
          {'name': 'Sentadillas', 'count': '50'},
          {'name': 'Abdominales', 'count': '50'},
        ],
      ),
      TrainingSectionData(
        section: TrainingSection.tecnica,
        title: 'SESIÓN DE TÉCNICA',
        duration: 3 * 60, // 3 minutos para demo
        exercises: [
          {'name': 'Jab directo', 'count': '100'},
          {'name': 'Cross derecho', 'count': '100'},
          {'name': 'Hook izquierdo', 'count': '100'},
          {'name': 'Uppercut', 'count': '100'},
        ],
      ),
    ];

    // Guardar tiempos objetivo
    for (final section in sections) {
      sectionTargets[section.section] = section.duration;
    }

    sessionStartTime = DateTime.now();
  }

  void _startSection(TrainingSection section) {
    final sectionData = sections.firstWhere((s) => s.section == section);

    setState(() {
      currentSection = section;
      remainingSeconds = sectionData.duration;
      originalSectionTime = sectionData.duration;
      _isRunning = false;
    });

    print('🏃‍♂️ [TrainingSession] Iniciando sección: ${sectionData.title}');
  }

  void _toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isRunning = false;
        });
        _onSectionTimeUp();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _onSectionTimeUp() {
    // Guardar tiempo usado para esta sección
    final timeUsed = originalSectionTime - remainingSeconds;
    sectionTimes[currentSection] = timeUsed;

    // Mostrar dialog de sección completada automáticamente
    _showSectionCompletedDialog(true);
  }

  void _onSectionCompleted() {
    // Guardar tiempo usado para esta sección
    final timeUsed = originalSectionTime - remainingSeconds;
    sectionTimes[currentSection] = timeUsed;

    _showSectionCompletedDialog(false);
  }

  void _showSectionCompletedDialog(bool automatic) {
    final sectionData = sections.firstWhere((s) => s.section == currentSection);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            automatic ? '⏰ Tiempo agotado' : '✅ Sección completada',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${sectionData.title} terminada',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Text(
                'Tiempo usado: ${_formatDuration(sectionTimes[currentSection] ?? 0)}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Tiempo objetivo: ${_formatDuration(sectionTargets[currentSection] ?? 0)}',
                style: const TextStyle(color: Colors.yellow),
              ),
            ],
          ),
          actions: [
            if (currentSection !=
                TrainingSection.tecnica) // Si no es la última sección
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _goToNextSection();
                },
                child: const Text(
                  'Siguiente sección',
                  style: TextStyle(color: Colors.green),
                ),
              )
            else // Si es la última sección
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _completeTraining();
                },
                child: const Text(
                  'Finalizar entrenamiento',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _abandonTraining();
              },
              child: const Text(
                'Abandonar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _goToNextSection() {
    switch (currentSection) {
      case TrainingSection.calentamiento:
        _startSection(TrainingSection.resistencia);
        break;
      case TrainingSection.resistencia:
        _startSection(TrainingSection.tecnica);
        break;
      case TrainingSection.tecnica:
        _completeTraining();
        break;
      case TrainingSection.completado:
        break;
    }
  }

  void _completeTraining() {
    final totalTimeUsed = sectionTimes.values.fold(
      0,
      (sum, time) => sum + time,
    );
    final totalTarget = sectionTargets.values.fold(
      0,
      (sum, time) => sum + time,
    );

    // Navegar a resumen final
    context.go(
      '/training-summary',
      extra: {
        'sectionTimes': sectionTimes,
        'sectionTargets': sectionTargets,
        'totalTimeUsed': totalTimeUsed,
        'totalTarget': totalTarget,
        'exerciseCount': _getTotalExerciseCount(),
        'sessionStartTime': sessionStartTime,
      },
    );
  }

  void _abandonTraining() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            '⚠️ ¿Abandonar entrenamiento?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Se perderá todo el progreso de la sesión actual.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Continuar',
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/boxer-home');
              },
              child: const Text(
                'Abandonar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  int _getTotalExerciseCount() {
    return sections.fold(0, (sum, section) => sum + section.exercises.length);
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSecs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSecs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentSectionData = sections.firstWhere(
      (s) => s.section == currentSection,
    );

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Indicador de progreso
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProgressIndicator(TrainingSection.calentamiento),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 16,
                      ),
                      _buildProgressIndicator(TrainingSection.resistencia),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 16,
                      ),
                      _buildProgressIndicator(TrainingSection.tecnica),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Header con timer
                BoxerTimerHeader(
                  isRunning: _isRunning,
                  remainingSeconds: remainingSeconds,
                  onToggle: _toggleTimer,
                  sessionTitle: currentSectionData.title,
                ),
                const SizedBox(height: 24),

                // Lista de ejercicios
                BoxerTimerTable(exercises: currentSectionData.exercises),
                const SizedBox(height: 24),

                // Botones de acción
                BoxerTimerActions(
                  onRetirarse: _abandonTraining,
                  onCompletado: _onSectionCompleted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(TrainingSection section) {
    final isCompleted = sectionTimes.containsKey(section);
    final isCurrent = section == currentSection;

    Color color;
    IconData icon;

    if (isCompleted) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (isCurrent) {
      color = Colors.yellow;
      icon = Icons.play_circle;
    } else {
      color = Colors.grey;
      icon = Icons.circle_outlined;
    }

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          _getSectionShortName(section),
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }

  String _getSectionShortName(TrainingSection section) {
    switch (section) {
      case TrainingSection.calentamiento:
        return 'Calent.';
      case TrainingSection.resistencia:
        return 'Resist.';
      case TrainingSection.tecnica:
        return 'Técnica';
      case TrainingSection.completado:
        return 'Fin';
    }
  }
}

class TrainingSectionData {
  final TrainingSection section;
  final String title;
  final int duration; // en segundos
  final List<Map<String, String>> exercises;

  TrainingSectionData({
    required this.section,
    required this.title,
    required this.duration,
    required this.exercises,
  });
}
