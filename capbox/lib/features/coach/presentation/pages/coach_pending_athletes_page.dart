import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/coach_header.dart';
import '../widgets/coach_navbar.dart';
import '../../../admin/presentation/cubit/gym_management_cubit.dart';
import '../../../admin/data/dtos/gym_member_dto.dart';

class CoachPendingAthletesPage extends StatefulWidget {
  const CoachPendingAthletesPage({super.key});

  @override
  State<CoachPendingAthletesPage> createState() =>
      _CoachPendingAthletesPageState();
}

class _CoachPendingAthletesPageState extends State<CoachPendingAthletesPage> {
  @override
  void initState() {
    super.initState();
    // Cargar atletas pendientes al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GymManagementCubit>().loadPendingRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const CoachNavBar(currentIndex: 2),
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset('assets/images/fondo.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),

          // Contenido
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CoachHeader(),
                      const SizedBox(height: 16),

                      // Título
                      const Text(
                        'Captura de Datos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Atletas esperando captura de datos',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de atletas pendientes
                Expanded(
                  child: Consumer<GymManagementCubit>(
                    builder: (context, cubit, child) {
                      if (cubit.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF0909),
                          ),
                        );
                      }

                      if (cubit.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                cubit.errorMessage ?? 'Error desconocido',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => cubit.loadPendingRequests(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF0909),
                                ),
                                child: const Text(
                                  'Reintentar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final pendingAthletes = cubit.pendingRequests;

                      if (pendingAthletes.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green.shade400,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                '¡Excelente!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'No hay atletas pendientes de captura de datos',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () => context.go('/coach-home'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF0909),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  'Volver al inicio',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          await cubit.loadPendingRequests();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: pendingAthletes.length,
                          itemBuilder: (context, index) {
                            final athlete = pendingAthletes[index];
                            return _buildAthleteCard(athlete);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAthleteCard(GymMemberDto athlete) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF0909).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: const Color(0xFFFF0909),
            radius: 24,
            child: Text(
              athlete.name.isNotEmpty ? athlete.name[0].toUpperCase() : 'A',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Información del atleta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  athlete.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  athlete.email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.withOpacity(0.5)),
                  ),
                  child: const Text(
                    'Pendiente de datos',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Botón capturar datos
          ElevatedButton(
            onPressed: () => _navigateToCaptureData(athlete),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF0909),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Capturar',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCaptureData(GymMemberDto athlete) {
    print('📝 Navegando a captura de datos para: ${athlete.name}');
    context.push('/coach/capture-data', extra: athlete);
  }
}
