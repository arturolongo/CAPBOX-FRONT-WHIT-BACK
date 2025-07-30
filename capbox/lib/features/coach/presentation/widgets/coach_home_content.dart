import 'package:flutter/material.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../admin/presentation/cubit/gym_management_cubit.dart';

class CoachHomeContent extends StatelessWidget {
  const CoachHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GymManagementCubit>(
      builder: (context, cubit, child) {
        final pendingRequests = cubit.pendingRequests.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CoachHeader(),
              const SizedBox(height: 24),
              const Text(
                'Hola Carlos :)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // primera fila horizontal
              Row(
                children: [
                  Expanded(
                    child: _buildStyledButton(
                      context,
                      'Lista de asistencia',
                      const Color(0xFF006F38),
                      route: '/coach-attendance',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStyledButton(
                      context,
                      'Rutinas',
                      const Color(0xFF006F38),
                      route: '/coach-routines',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Botón de clave del gimnasio
              _buildStyledButton(
                context,
                'Clave del Gimnasio',
                const Color(0xFFFF0909),
                route: '/coach/gym-key',
                icon: Icons.key,
              ),
              const SizedBox(height: 12),

              // Lista vertical
              _buildStyledButton(
                context,
                'Asignar metas individuales',
                const Color(0xFF006F38),
                route: '/coach/assign-goals',
              ),
              const SizedBox(height: 12),

              Stack(
                children: [
                  _buildStyledButton(
                    context,
                    'Captura de datos de alumno',
                    const Color.fromRGBO(113, 113, 113, 0.5),
                    route: '/coach/pending-athletes',
                  ),
                  if (pendingRequests > 0)
                    Positioned(
                      right: 16,
                      top: 8,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: Text(
                          '$pendingRequests',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStyledButton(
                context,
                'Realizar toma de pruebas',
                const Color.fromRGBO(113, 113, 113, 0.5),
                route: '/coach-select-student-for-test',
              ),
              const SizedBox(height: 12),
              _buildStyledButton(
                context,
                'HERRAMIENTAS DE IA',
                const Color.fromRGBO(246, 255, 0, 0.34),
                route: '/coach-ai-tools',
              ),
              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStyledButton(
    BuildContext context,
    String text,
    Color color, {
    String? route,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: () {
          if (route != null) {
            context.go(route);
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child:
            icon != null
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                )
                : Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
      ),
    );
  }
}
