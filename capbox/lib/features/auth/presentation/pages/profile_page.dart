import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../view_models/aws_login_cubit.dart';
import '../../domain/entities/user.dart';
import '../../../../core/services/aws_api_service.dart';
import 'package:capbox/features/admin/presentation/widgets/admin_navbar.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';

class ProfilePage extends StatelessWidget {
  final int currentIndex;
  final UserRole? userRole;
  const ProfilePage({super.key, this.currentIndex = 1, this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: _buildNavBar(context),
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
                _buildHeader(context),
                const SizedBox(height: 24),
                // Información del usuario
                Expanded(child: _buildUserInfo(context)),
                // Botón de cerrar sesión
                _buildLogoutButton(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    final loginCubit = Provider.of<AWSLoginCubit>(context, listen: false);
    final role = userRole ?? loginCubit.currentUser?.role;

    // Usar el currentIndex que se pasa como parámetro
    if (role == UserRole.admin) {
      return AdminNavBar(currentIndex: currentIndex);
    } else if (role == UserRole.coach) {
      return CoachNavBar(currentIndex: currentIndex);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        'Mi Perfil',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Consumer<AWSLoginCubit>(
      builder: (context, loginCubit, child) {
        final user = loginCubit.currentUser;

        if (user == null) {
          return const Center(
            child: Text(
              'No se pudo cargar la información del usuario',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.red,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Nombre completo
              _buildInfoCard(
                icon: Icons.person,
                title: 'Nombre Completo',
                value: user.name,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),

              // Email
              _buildInfoCard(
                icon: Icons.email,
                title: 'Correo Electrónico',
                value: user.email,
                color: Colors.green,
              ),
              const SizedBox(height: 16),

              // Rol
              _buildInfoCard(
                icon: Icons.work,
                title: 'Rol',
                value: _getRoleDisplayName(user.role),
                color: Colors.orange,
              ),
              const SizedBox(height: 16),

              // Gimnasio (si está disponible)
              FutureBuilder<Map<String, dynamic>?>(
                future: _getGymInfo(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildInfoCard(
                      icon: Icons.sports,
                      title: 'Gimnasio',
                      value: 'Cargando...',
                      color: Colors.purple,
                    );
                  }

                  final gymInfo = snapshot.data;
                  if (gymInfo != null) {
                    return _buildInfoCard(
                      icon: Icons.sports,
                      title: 'Gimnasio',
                      value: gymInfo['nombre'] ?? 'Sin nombre',
                      color: Colors.purple,
                    );
                  } else {
                    return _buildInfoCard(
                      icon: Icons.sports,
                      title: 'Gimnasio',
                      value: 'No vinculado',
                      color: Colors.red,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showLogoutDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 20),
              SizedBox(width: 8),
              Text(
                'Cerrar Sesión',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Cerrar Sesión',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    try {
      final loginCubit = context.read<AWSLoginCubit>();
      await loginCubit.logout();

      if (context.mounted) {
        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.coach:
        return 'Entrenador';
      case UserRole.athlete:
        return 'Atleta';
    }
  }

  Future<Map<String, dynamic>?> _getGymInfo(BuildContext context) async {
    try {
      final loginCubit = context.read<AWSLoginCubit>();
      final user = loginCubit.currentUser;

      if (user == null) return null;

      // Obtener información del gimnasio desde el backend
      final apiService = context.read<AWSApiService>();
      final response = await apiService.getUserMe();
      final userData = response.data;

      // Verificar si el usuario está vinculado a un gimnasio
      final gimnasio = userData['gimnasio'];
      if (gimnasio != null) {
        return gimnasio;
      }

      return null;
    } catch (e) {
      print('Error obteniendo información del gimnasio: $e');
      return null;
    }
  }
}
