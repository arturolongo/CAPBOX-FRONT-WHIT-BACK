import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/coach_header.dart';
import '../widgets/coach_navbar.dart';
import '../cubit/gym_key_cubit.dart';

class CoachGymKeyPage extends StatefulWidget {
  const CoachGymKeyPage({super.key});

  @override
  State<CoachGymKeyPage> createState() => _CoachGymKeyPageState();
}

class _CoachGymKeyPageState extends State<CoachGymKeyPage> {
  @override
  void initState() {
    super.initState();
    // Cargar la clave al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GymKeyCubit>().loadGymKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const CoachNavBar(currentIndex: 1),
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CoachHeader(),
                  const SizedBox(height: 24),

                  // Título
                  const Text(
                    'Clave del Gimnasio',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Esta es tu clave del gimnasio.\nCompártela con nuevos boxeadores para que puedan registrarse.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      fontFamily: 'Inter',
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Contenido principal
                  Expanded(
                    child: Consumer<GymKeyCubit>(
                      builder: (context, gymKeyCubit, child) {
                        return _buildContent(gymKeyCubit);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(GymKeyCubit gymKeyCubit) {
    if (gymKeyCubit.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Cargando clave del gimnasio...',
              style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
            ),
          ],
        ),
      );
    }

    if (gymKeyCubit.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              gymKeyCubit.errorMessage ?? 'Error cargando la clave',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => gymKeyCubit.refreshGymKey(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF0909),
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (gymKeyCubit.hasKey) {
      return _buildKeyDisplay(gymKeyCubit);
    }

    return const Center(
      child: Text(
        'No se pudo cargar la clave del gimnasio',
        style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
      ),
    );
  }

  Widget _buildKeyDisplay(GymKeyCubit gymKeyCubit) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Tarjeta principal de la clave
          _buildKeyCard(gymKeyCubit),

          const SizedBox(height: 24),

          // Botones de acción
          _buildActionButtons(gymKeyCubit),

          const SizedBox(height: 24),

          // Información adicional
          _buildKeyInfo(gymKeyCubit),

          const SizedBox(height: 24),

          // Instrucciones
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildKeyCard(GymKeyCubit gymKeyCubit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF0909).withOpacity(0.8),
            const Color(0xFFFF0909),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF0909).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.key, color: Colors.white, size: 48),

          const SizedBox(height: 16),

          const Text(
            'Clave de Acceso',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              gymKeyCubit.gymKey!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier', // Fuente monoespaciada
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(GymKeyCubit gymKeyCubit) {
    return Row(
      children: [
        // Botón copiar
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _copyToClipboard(gymKeyCubit),
            icon: const Icon(Icons.copy),
            label: const Text('Copiar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Botón compartir
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _shareKey(gymKeyCubit),
            icon: const Icon(Icons.share),
            label: const Text('Compartir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Botón refrescar
        IconButton(
          onPressed: () => gymKeyCubit.refreshGymKey(),
          icon: const Icon(Icons.refresh),
          color: Colors.white,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyInfo(GymKeyCubit gymKeyCubit) {
    final keyInfo = gymKeyCubit.getKeyInfo();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información de la Clave',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),

          const SizedBox(height: 12),

          ...keyInfo.entries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${entry.key}:',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        entry.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Instrucciones para Atletas',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            '1. Descarga la aplicación CapBox\n'
            '2. Toca "Registrarse"\n'
            '3. Selecciona "Boxeador" como rol\n'
            '4. Ingresa esta clave en el campo correspondiente\n'
            '5. Completa el registro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Inter',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(GymKeyCubit gymKeyCubit) {
    if (gymKeyCubit.gymKey != null) {
      Clipboard.setData(ClipboardData(text: gymKeyCubit.gymKey!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clave copiada al portapapeles'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareKey(GymKeyCubit gymKeyCubit) {
    final shareText = gymKeyCubit.getShareText();

    // En Flutter real usarías: Share.share(shareText)
    // Por ahora, simular compartir copiando al portapapeles
    Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Mensaje de invitación copiado. Puedes pegarlo en WhatsApp, Telegram, etc.',
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
