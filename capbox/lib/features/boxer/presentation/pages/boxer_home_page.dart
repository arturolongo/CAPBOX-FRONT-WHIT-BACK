import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capbox/features/boxer/presentation/widgets/boxer_header.dart';
import 'package:capbox/features/boxer/presentation/widgets/boxer_navbar.dart';
import 'package:capbox/features/boxer/presentation/widgets/boxer_streak_goals.dart';
import 'package:capbox/features/boxer/presentation/widgets/boxer_exercises.dart';
import 'package:capbox/core/services/aws_api_service.dart';

class BoxerHomePage extends StatefulWidget {
  const BoxerHomePage({super.key});

  @override
  State<BoxerHomePage> createState() => _BoxerHomePageState();
}

class _BoxerHomePageState extends State<BoxerHomePage> {
  String? userRole;
  String? athleteStatus;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAthleteStatus();
  }

  Future<void> _checkAthleteStatus({bool forceRefresh = false}) async {
    if (!forceRefresh && !isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      print('🔄 [BoxerHomePage] Verificando estado del atleta');
      final apiService = context.read<AWSApiService>();
      final response = await apiService.getUserMe();
      final userData = response.data;

      setState(() {
        userRole = userData['rol'];
        athleteStatus = userData['estado_atleta'];
        isLoading = false;
      });

      print(
        '✅ [BoxerHomePage] Estado verificado - Rol: $userRole, Estado: $athleteStatus',
      );
    } catch (e) {
      print('❌ [BoxerHomePage] Error verificando estado: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    print('🔄 [BoxerHomePage] Actualizando datos...');
    await _checkAthleteStatus(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const BoxerNavBar(currentIndex: 1),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/fondo.png', fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
            SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BoxerHeader(),
                    const SizedBox(height: 16),

                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (userRole == 'Atleta' &&
                        athleteStatus == 'pendiente_datos')
                      _buildPendingDataContent()
                    else if (userRole == 'Atleta' && athleteStatus == 'activo')
                      _buildActiveAthleteContent()
                    else
                      _buildErrorContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingDataContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange),
          ),
          child: const Column(
            children: [
              Icon(Icons.pending, color: Colors.orange, size: 48),
              SizedBox(height: 8),
              Text(
                'Datos pendientes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tu entrenador debe capturar tus datos físicos para activar tu cuenta.',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _refreshData(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text(
              'Actualizar Estado',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveAthleteContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sección de racha y ejercicios (contenido original)
        const BoxerStreakGoals(),
        const SizedBox(height: 16),
        const BoxerExercises(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildErrorContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          const Text(
            'Error cargando datos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rol: ${userRole ?? 'Desconocido'}\nEstado: ${athleteStatus ?? 'Desconocido'}',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _refreshData(),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
