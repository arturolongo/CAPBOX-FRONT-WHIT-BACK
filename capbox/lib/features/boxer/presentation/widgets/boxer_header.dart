import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/user_display_service.dart';
import '../../../../core/services/auth_service.dart';

class BoxerHeader extends StatelessWidget {
  const BoxerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Perfil del usuario con datos reales
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Image.asset(
                'assets/icons/nombre_card.png',
                height: 90,
                width: 260,
                fit: BoxFit.fill,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 46, bottom: 11),
                child: FutureBuilder<UserDisplayData>(
                  future:
                      context
                          .read<UserDisplayService>()
                          .getCurrentUserDisplayData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 14, // Mismo tamaño que el avatar real
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Cargando...',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    }

                    final userData = snapshot.data;
                    final displayName = userData?.displayName ?? 'Boxeador';
                    final avatarInitial = userData?.avatarInitial ?? 'B';

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 14, // Reducir tamaño del avatar
                          child: Text(
                            avatarInitial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12, // Reducir tamaño del texto
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Logo CAPBOX
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Image.asset('assets/images/logo.png', height: 56),
        ),

        // Botón de cerrar sesión
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _showLogoutDialog(context),
          icon: const Icon(Icons.logout, color: Colors.white, size: 24),
          tooltip: 'Cerrar sesión',
        ),
      ],
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
              onPressed: () async {
                Navigator.of(context).pop();
                await _logout(context);
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

  Future<void> _logout(BuildContext context) async {
    try {
      final authService = context.read<AuthService>();
      await authService.cerrarSesion();

      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cerrar sesión'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
