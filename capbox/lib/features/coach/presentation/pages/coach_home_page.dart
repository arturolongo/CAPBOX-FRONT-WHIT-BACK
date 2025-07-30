import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_home_content.dart';
import '../../../admin/presentation/cubit/gym_management_cubit.dart';

class CoachHomePage extends StatefulWidget {
  const CoachHomePage({super.key});

  @override
  State<CoachHomePage> createState() => _CoachHomePageState();
}

class _CoachHomePageState extends State<CoachHomePage> {
  @override
  void initState() {
    super.initState();
    // Cargar solicitudes pendientes al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GymManagementCubit>().loadPendingRequests();
    });
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
          const SafeArea(child: CoachHomeContent()),
        ],
      ),
    );
  }
}
