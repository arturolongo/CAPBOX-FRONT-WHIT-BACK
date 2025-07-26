import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/admin_header.dart';
import '../widgets/admin_navbar.dart';
import '../../data/services/admin_gym_key_service.dart';
import '../cubit/admin_gym_key_cubit.dart';

class AdminGymKeyPage extends StatefulWidget {
  const AdminGymKeyPage({super.key});

  @override
  State<AdminGymKeyPage> createState() => _AdminGymKeyPageState();
}

class _AdminGymKeyPageState extends State<AdminGymKeyPage> {
  final TextEditingController _keyController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Cargar la clave actual al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminGymKeyCubit>().loadGymKey();
    });
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const AdminNavBar(currentIndex: 1),
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
                  // Header
                  const AdminHeader(),

                  const SizedBox(height: 24),

                  // Botón volver
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/admin-home'),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Gestión de Clave del Gimnasio',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Contenido principal
                  Expanded(
                    child: Consumer<AdminGymKeyCubit>(
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
                                  onPressed: () => cubit.loadGymKey(),
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

                        return _buildGymKeyContent(cubit);
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

  Widget _buildGymKeyContent(AdminGymKeyCubit cubit) {
    // MANEJAR ESTADOS SIN MOCK - MOSTRAR REALIDAD
    if (cubit.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFFF0909)),
            SizedBox(height: 16),
            Text(
              'Cargando clave del gimnasio...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      );
    }

    if (cubit.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Error cargando clave del gimnasio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cubit.errorMessage ?? 'Error desconocido',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => cubit.loadGymKey(),
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

    if (!cubit.hasData) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.key_off, color: Colors.white54, size: 64),
            SizedBox(height: 16),
            Text(
              'No hay clave configurada',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Configure una clave para su gimnasio',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      );
    }

    // SI LLEGAMOS AQUÍ, HAY CLAVE VÁLIDA
    final currentKey = cubit.gymKey!;

    // Si estamos editando, mostrar el valor del controlador, sino el valor actual
    if (!_isEditing) {
      _keyController.text = currentKey;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card principal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFF0909).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título con icono
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0909).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.key,
                        color: Color(0xFFFF0909),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clave del Gimnasio',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Administra la clave única de tu gimnasio',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Campo de clave
                const Text(
                  'Clave actual:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        _isEditing
                            ? Colors.white.withOpacity(0.1)
                            : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _isEditing
                              ? const Color(0xFFFF0909)
                              : Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child:
                      _isEditing
                          ? TextField(
                            controller: _keyController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'gym1234',
                              hintStyle: TextStyle(color: Colors.white54),
                            ),
                            maxLength: 8, // gymXXXX
                            textCapitalization: TextCapitalization.characters,
                          )
                          : Row(
                            children: [
                              Expanded(
                                child: Text(
                                  currentKey,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _copyToClipboard(currentKey),
                                icon: const Icon(
                                  Icons.copy,
                                  color: Color(0xFFFF0909),
                                ),
                                tooltip: 'Copiar clave',
                              ),
                            ],
                          ),
                ),

                const SizedBox(height: 24),

                // Botones de acción
                Row(
                  children: [
                    if (_isEditing) ...[
                      // Botón cancelar
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _cancelEdit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Botón guardar
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : () => _saveKey(cubit),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF0909),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              _isSaving
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    'Guardar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),
                    ] else ...[
                      // Botón editar
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _startEdit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF0909),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text(
                            'Editar Clave',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Botón compartir
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _shareKey(currentKey),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.share),
                          label: const Text(
                            'Compartir',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Información adicional
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade300, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Información importante',
                      style: TextStyle(
                        color: Colors.blue.shade300,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const Text(
                  '• Esta clave será usada por entrenadores para registrar nuevos boxeadores\n'
                  '• Los entrenadores también necesitarán esta clave para registrarse\n'
                  '• Puedes cambiar la clave en cualquier momento\n'
                  '• Comparte la clave de forma segura con tus entrenadores',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botón generar nueva clave
          if (!_isEditing)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateNewKey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Generar Nueva Clave',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _startEdit() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });
  }

  void _generateNewKey() {
    final random = DateTime.now().millisecondsSinceEpoch.remainder(10000);
    final newKey = 'gym${random.toString().padLeft(4, '0')}';

    _keyController.text = newKey;
    setState(() {
      _isEditing = true;
    });
  }

  Future<void> _saveKey(AdminGymKeyCubit cubit) async {
    final newKey = _keyController.text.trim();

    if (newKey.isEmpty) {
      _showError('La clave no puede estar vacía');
      return;
    }

    // Validar formato libre: al menos 1 mayúscula y 1 número
    if (!_isValidKeyFormat(newKey)) {
      _showError('La clave debe tener al menos una mayúscula y un número');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Llamada REAL al backend para guardar la clave
      await cubit.updateGymKey(newKey);

      _showSuccess('Clave actualizada exitosamente');

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
    } catch (e) {
      _showError('Error guardando la clave: $e');
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _copyToClipboard(String key) {
    Clipboard.setData(ClipboardData(text: key));
    _showSuccess('Clave copiada al portapapeles');
  }

  void _shareKey(String key) {
    // Copiar al portapapeles en lugar de compartir
    Clipboard.setData(
      ClipboardData(
        text:
            'Clave del Gimnasio CapBox: $key\n\nUsa esta clave para registrarte como entrenador o registrar nuevos boxeadores.',
      ),
    );
    _showSuccess('Información de la clave copiada al portapapeles');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Validar formato de clave: debe tener al menos 1 mayúscula y 1 número
  bool _isValidKeyFormat(String key) {
    if (key.isEmpty) return false;

    // Verificar que tenga al menos una mayúscula
    final hasUppercase = key.contains(RegExp(r'[A-Z]'));

    // Verificar que tenga al menos un número
    final hasNumber = key.contains(RegExp(r'[0-9]'));

    return hasUppercase && hasNumber;
  }
}
