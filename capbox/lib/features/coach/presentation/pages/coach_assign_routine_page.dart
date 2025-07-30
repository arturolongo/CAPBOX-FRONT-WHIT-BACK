import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';
import 'package:capbox/features/coach/presentation/widgets/routine_card_assign.dart';
import 'package:capbox/features/coach/data/services/routine_service.dart';
import 'package:capbox/features/coach/data/dtos/routine_dto.dart';
import 'package:capbox/core/services/aws_api_service.dart';

class CoachAssignRoutinePage extends StatefulWidget {
  final String nivel;
  const CoachAssignRoutinePage({super.key, required this.nivel});

  @override
  State<CoachAssignRoutinePage> createState() => _CoachAssignRoutinePageState();
}

class _CoachAssignRoutinePageState extends State<CoachAssignRoutinePage> {
  int? expandedIndex;
  String selectedCategory = 'calentamiento';
  List<RoutineDetailDto> rutinasConDetalles = [];
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      print(
        '🔄 [CoachAssignRoutinePage] Cargando rutinas desde backend para nivel: ${widget.nivel}',
      );
      final apiService = context.read<AWSApiService>();
      final service = RoutineService(apiService);

      // Primero obtenemos la lista de rutinas
      final routinesList = await service.getRoutines(nivel: widget.nivel);
      print(
        '✅ [CoachAssignRoutinePage] ${routinesList.length} rutinas encontradas',
      );

      // Luego obtenemos los detalles de cada rutina
      final List<RoutineDetailDto> rutinasDetalladas = [];
      for (final rutina in routinesList) {
        try {
          final detalle = await service.getRoutineDetail(rutina.id);
          rutinasDetalladas.add(detalle);
          print(
            '✅ [CoachAssignRoutinePage] Detalle cargado para: ${rutina.nombre}',
          );
        } catch (e) {
          print(
            '❌ [CoachAssignRoutinePage] Error cargando detalle de ${rutina.nombre}: $e',
          );
        }
      }

      setState(() {
        rutinasConDetalles = rutinasDetalladas;
        isLoading = false;
      });

      print(
        '✅ [CoachAssignRoutinePage] ${rutinasConDetalles.length} rutinas con detalles cargadas',
      );
    } catch (e) {
      print('❌ [CoachAssignRoutinePage] Error al cargar rutinas: $e');
      setState(() {
        errorMsg = 'Error al cargar rutinas: $e';
        isLoading = false;
      });
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
                  const SizedBox(height: 20),
                  Text(
                    'Asignar rutinas - ${widget.nivel}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (errorMsg != null)
                    Center(
                      child: Text(
                        errorMsg!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  else if (rutinasConDetalles.isEmpty)
                    const Center(
                      child: Text(
                        'No hay rutinas para este nivel.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: rutinasConDetalles.length,
                        itemBuilder:
                            (context, index) => RoutineCardAssign(
                              routine: rutinasConDetalles[index],
                              nivel: widget.nivel,
                              index: index,
                              expandedIndex: expandedIndex,
                              selectedCategory: selectedCategory,
                              onExpand: (newIndex) {
                                setState(() {
                                  expandedIndex = newIndex;
                                  selectedCategory = 'calentamiento';
                                });
                              },
                              onCategoryChange: (newCategory) {
                                setState(() => selectedCategory = newCategory);
                              },
                            ),
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
}
