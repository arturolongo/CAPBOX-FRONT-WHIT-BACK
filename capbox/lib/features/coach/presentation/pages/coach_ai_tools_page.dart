import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/coach_header.dart';
import '../widgets/coach_navbar.dart';
import '../../../../core/services/aws_api_service.dart';

class CoachAiToolsPage extends StatefulWidget {
  const CoachAiToolsPage({super.key});

  @override
  State<CoachAiToolsPage> createState() => _CoachAiToolsPageState();
}

class _CoachAiToolsPageState extends State<CoachAiToolsPage> {
  List<StudentData> _students = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGymStudents();
  }

  Future<void> _loadGymStudents() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Simular carga de estudiantes del gimnasio
      await Future.delayed(const Duration(milliseconds: 800));

      // Generar datos emulados de estudiantes del gimnasio
      final emulatedStudents = _generateEmulatedStudents();

      setState(() {
        _students = emulatedStudents;
        _isLoading = false;
      });

      print('🤖 AI TOOLS: ${_students.length} estudiantes cargados');
    } catch (e) {
      print('❌ AI TOOLS: Error cargando estudiantes - $e');
      setState(() {
        _errorMessage = 'Error cargando estudiantes del gimnasio';
        _isLoading = false;
      });
    }
  }

  List<StudentData> _generateEmulatedStudents() {
    // Generar estudiantes emulados del gimnasio
    return [
      StudentData(
        id: '1',
        name: 'Arturo Jimenez',
        level: 'Principiante',
        age: 16,
        weight: 65,
        height: 1.70,
        fights: 3,
        wins: 2,
        losses: 1,
        category: 'Peso Pluma',
      ),
      StudentData(
        id: '2',
        name: 'Carlos Rodriguez',
        level: 'Intermedio',
        age: 18,
        weight: 72,
        height: 1.75,
        fights: 8,
        wins: 6,
        losses: 2,
        category: 'Peso Ligero',
      ),
      StudentData(
        id: '3',
        name: 'Miguel Torres',
        level: 'Avanzado',
        age: 20,
        weight: 78,
        height: 1.78,
        fights: 15,
        wins: 12,
        losses: 3,
        category: 'Peso Medio',
      ),
      StudentData(
        id: '4',
        name: 'Luis Martinez',
        level: 'Principiante',
        age: 17,
        weight: 68,
        height: 1.72,
        fights: 2,
        wins: 1,
        losses: 1,
        category: 'Peso Pluma',
      ),
      StudentData(
        id: '5',
        name: 'Roberto Silva',
        level: 'Intermedio',
        age: 19,
        weight: 75,
        height: 1.76,
        fights: 10,
        wins: 7,
        losses: 3,
        category: 'Peso Ligero',
      ),
      StudentData(
        id: '6',
        name: 'Diego Herrera',
        level: 'Avanzado',
        age: 21,
        weight: 82,
        height: 1.80,
        fights: 18,
        wins: 15,
        losses: 3,
        category: 'Peso Medio',
      ),
    ];
  }

  List<StudentData> _getBestOpponents(StudentData student) {
    // Filtrar estudiantes del mismo nivel
    final sameLevelStudents =
        _students
            .where((s) => s.id != student.id && s.level == student.level)
            .toList();

    // Solo mostrar contrincantes si hay más de un estudiante en el mismo nivel
    if (sameLevelStudents.isEmpty) {
      return [];
    }

    // Ordenar por experiencia (más peleas) y rendimiento (ratio de victorias)
    sameLevelStudents.sort((a, b) {
      final aRatio = a.fights > 0 ? a.wins / a.fights : 0;
      final bRatio = b.fights > 0 ? b.wins / b.fights : 0;

      // Priorizar por ratio de victorias, luego por número de peleas
      if (aRatio != bRatio) {
        return bRatio.compareTo(aRatio);
      }
      return b.fights.compareTo(a.fights);
    });

    // Retornar los 2 mejores
    return sameLevelStudents.take(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const CoachNavBar(currentIndex: 0),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/fondo.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CoachHeader(),
                ),
                Expanded(
                  child:
                      _isLoading
                          ? const Center(
                            child: CircularProgressIndicator(color: Colors.red),
                          )
                          : _errorMessage != null
                          ? _buildErrorWidget()
                          : _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadGymStudents,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Reintentar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, color: Colors.white70, size: 64),
            const SizedBox(height: 16),
            const Text(
              'No hay estudiantes en el gimnasio',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Agrega estudiantes para ver recomendaciones de contrincantes',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '🤖 Herramientas de IA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Mejores contrincantes por nivel (${_students.length} estudiantes)',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students[index];
              final opponents = _getBestOpponents(student);

              return _buildStudentCard(student, opponents);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(StudentData student, List<StudentData> opponents) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del estudiante
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getLevelColor(student.level),
                  radius: 20,
                  child: Text(
                    student.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getLevelColor(student.level),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              student.level,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            student.category,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${student.fights} peleas',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${student.wins}W - ${student.losses}L',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Contrincantes recomendados
            Text(
              '🥊 Mejores contrincantes:',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            if (opponents.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Sin contrincantes disponibles en este nivel',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ...opponents.map((opponent) => _buildOpponentCard(opponent)),
          ],
        ),
      ),
    );
  }

  Widget _buildOpponentCard(StudentData opponent) {
    final winRatio = opponent.fights > 0 ? opponent.wins / opponent.fights : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getLevelColor(opponent.level),
            radius: 16,
            child: Text(
              opponent.name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opponent.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${opponent.category} • ${opponent.fights} peleas',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(winRatio * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${opponent.wins}W-${opponent.losses}L',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'principiante':
        return Colors.blue;
      case 'intermedio':
        return Colors.orange;
      case 'avanzado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class StudentData {
  final String id;
  final String name;
  final String level;
  final int age;
  final double weight;
  final double height;
  final int fights;
  final int wins;
  final int losses;
  final String category;

  StudentData({
    required this.id,
    required this.name,
    required this.level,
    required this.age,
    required this.weight,
    required this.height,
    required this.fights,
    required this.wins,
    required this.losses,
    required this.category,
  });

  factory StudentData.fromJson(Map<String, dynamic> json) {
    return StudentData(
      id: json['id'] ?? '',
      name: json['name'] ?? json['nombre'] ?? 'Estudiante',
      level: json['level'] ?? json['nivel'] ?? 'Principiante',
      age: json['age'] ?? json['edad'] ?? 0,
      weight: (json['weight'] ?? json['peso'] ?? 0).toDouble(),
      height: (json['height'] ?? json['altura'] ?? 0).toDouble(),
      fights: json['fights'] ?? json['peleas'] ?? 0,
      wins: json['wins'] ?? json['victorias'] ?? 0,
      losses: json['losses'] ?? json['derrotas'] ?? 0,
      category: json['category'] ?? json['categoria'] ?? 'Sin categoría',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'age': age,
      'weight': weight,
      'height': height,
      'fights': fights,
      'wins': wins,
      'losses': losses,
      'category': category,
    };
  }
}
