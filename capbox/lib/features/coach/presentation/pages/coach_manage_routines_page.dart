import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';
import 'package:capbox/features/coach/data/services/routine_service.dart';
import 'package:capbox/features/coach/data/dtos/routine_dto.dart';
import 'package:capbox/core/services/aws_api_service.dart';

class CoachManageRoutinesPage extends StatefulWidget {
  const CoachManageRoutinesPage({super.key});

  @override
  State<CoachManageRoutinesPage> createState() =>
      _CoachManageRoutinesPageState();
}

class _CoachManageRoutinesPageState extends State<CoachManageRoutinesPage> {
  Map<String, List<RoutineListDto>> rutinasPorNivel = {
    'avanzado': [],
    'intermedio': [],
    'principiante': [],
    'general': [],
  };

  Map<String, bool> loadingStates = {
    'avanzado': false,
    'intermedio': false,
    'principiante': false,
    'general': false,
  };

  Map<String, String?> errorStates = {
    'avanzado': null,
    'intermedio': null,
    'principiante': null,
    'general': null,
  };

  @override
  void initState() {
    super.initState();
    _loadAndGroupAllRoutines();
  }

  Future<void> _loadAndGroupAllRoutines() async {
    print(
      '🔄 [CoachManageRoutinesPage] Cargando TODAS las rutinas y agrupando por nivel',
    );
    setState(() {
      loadingStates.updateAll((key, value) => true);
      errorStates.updateAll((key, value) => null);
    });
    try {
      final apiService = context.read<AWSApiService>();
      final routineService = RoutineService(apiService);
      final todasRutinas = await routineService.getRoutines();
      // Agrupar por nivel ignorando mayúsculas/minúsculas
      Map<String, List<RoutineListDto>> agrupadas = {
        'avanzado': [],
        'intermedio': [],
        'principiante': [],
        'general': [],
      };

      // Debug: Mostrar niveles exactos que llegan del backend
      print('🔍 [CoachManageRoutinesPage] Niveles exactos de las rutinas:');
      for (final rutina in todasRutinas) {
        print('  - "${rutina.nombre}": nivel="${rutina.nivel}"');
      }

      for (final rutina in todasRutinas) {
        final nivel = rutina.nivel.toLowerCase();
        print(
          '🔍 [CoachManageRoutinesPage] Agrupando "${rutina.nombre}" con nivel="$nivel"',
        );
        if (agrupadas.containsKey(nivel)) {
          agrupadas[nivel]!.add(rutina);
          print('  ✅ Agregada a grupo "$nivel"');
        } else {
          // Si el nivel no es uno de los conocidos, lo puedes agregar a 'general' o ignorar
          agrupadas['general']!.add(rutina);
          print('  ⚠️ Agregada a grupo "general" (nivel no reconocido)');
        }
      }
      setState(() {
        rutinasPorNivel = agrupadas;
        loadingStates.updateAll((key, value) => false);
      });
      print('✅ [CoachManageRoutinesPage] Rutinas agrupadas por nivel:');
      agrupadas.forEach((nivel, rutinas) {
        print('  $nivel: ${rutinas.length}');
      });
    } catch (e) {
      print('❌ [CoachManageRoutinesPage] Error cargando rutinas: $e');
      setState(() {
        errorStates.updateAll((key, value) => 'Error: $e');
        loadingStates.updateAll((key, value) => false);
      });
    }
  }

  void _navigateToLevel(BuildContext context, String nivel) {
    print(
      '🔄 [CoachManageRoutinesPage] Navegando a gestión de rutinas nivel: $nivel',
    );
    context.go('/coach/manage/$nivel');
  }

  Future<void> _deleteRoutine(String routineId, String nivel) async {
    final nivelKey = nivel.toLowerCase();

    try {
      print('🔄 [CoachManageRoutinesPage] Eliminando rutina: $routineId');
      final apiService = context.read<AWSApiService>();
      final routineService = RoutineService(apiService);
      await routineService.deleteRoutine(routineId);

      print('✅ [CoachManageRoutinesPage] Rutina eliminada exitosamente');

      // Recargar rutinas del nivel
      await _loadAndGroupAllRoutines(); // Recargar todas las rutinas

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rutina eliminada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ [CoachManageRoutinesPage] Error eliminando rutina: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error eliminando rutina: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const CoachNavBar(currentIndex: 1),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/fondo.png', fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CoachHeader(),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  const Text(
                    'Gestionar rutinas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Lista de niveles con contadores
                  Expanded(
                    child: Column(
                      children: [
                        _buildLevelButton(
                          context,
                          'Rutinas para avanzados',
                          'avanzado',
                        ),
                        _buildLevelButton(
                          context,
                          'Rutinas para intermedios',
                          'intermedio',
                        ),
                        _buildLevelButton(
                          context,
                          'Rutinas para principiantes',
                          'principiante',
                        ),
                        _buildLevelButton(
                          context,
                          'Rutinas generales',
                          'general',
                        ),

                        const SizedBox(height: 30),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 16),

                        // Botones de acción
                        _buildSolidButton(context, 'Crear rutina', () {
                          print(
                            '🔄 [CoachManageRoutinesPage] Navegando a crear rutina',
                          );
                          context.go('/coach/create-routine');
                        }),
                        const SizedBox(height: 12),
                        _buildSolidButton(context, 'Volver', () {
                          print(
                            '🔄 [CoachManageRoutinesPage] Navegando de vuelta a rutinas',
                          );
                          context.go('/coach-routines');
                        }),
                        const SizedBox(height: 12),
                        // 🧪 BOTÓN TEMPORAL: Forzar logout/login para token fresco
                        _buildDebugButton(
                          context,
                          '🔄 Token Fresco (Debug)',
                          () async {
                            try {
                              print(
                                '🧪 [DEBUG] Forzando logout para token fresco...',
                              );

                              // Limpiar storage directamente
                              final storage = FlutterSecureStorage();
                              await storage.deleteAll();

                              print(
                                '✅ [DEBUG] Storage limpiado, redirigiendo a login...',
                              );

                              // Navegar a login
                              if (context.mounted) {
                                context.go('/login');

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Sesión cerrada. Inicia sesión para obtener token fresco.',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            } catch (e) {
                              print('❌ [DEBUG] Error en logout forzado: $e');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, String label, String nivel) {
    final rutinas = rutinasPorNivel[nivel] ?? [];
    final isLoading = loadingStates[nivel] ?? false;
    final error = errorStates[nivel];

    String displayText = label;
    if (isLoading) {
      displayText += ' (Cargando...)';
    } else if (error != null) {
      displayText += ' (Error)';
    } else {
      displayText += ' (${rutinas.length})';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        height: 49,
        child: ElevatedButton(
          onPressed: () => _navigateToLevel(context, nivel),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(
              255,
              15,
              253,
              197,
            ).withOpacity(0.15),
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  displayText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else if (error != null)
                const Icon(Icons.error, color: Colors.red, size: 16)
              else
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSolidButton(
    BuildContext context,
    String label,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 41,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A5B4B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
        ),
      ),
    );
  }

  Widget _buildDebugButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 41,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
        ),
      ),
    );
  }
}
