import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../cubit/admin_gym_key_cubit.dart';
import '../widgets/admin_header.dart';

/// Página para que el admin gestione la clave del gimnasio
class AdminGymKeyPage extends StatefulWidget {
  const AdminGymKeyPage({super.key});

  @override
  State<AdminGymKeyPage> createState() => _AdminGymKeyPageState();
}

class _AdminGymKeyPageState extends State<AdminGymKeyPage> {
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _gymNameController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Cargar datos al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = Provider.of<AdminGymKeyCubit>(context, listen: false);
      cubit.loadGymKey();
    });
  }

  @override
  void dispose() {
    _keyController.dispose();
    _gymNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fondo
          Image.asset(
            'assets/images/fondo.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(color: Colors.black.withOpacity(0.6)),

          // Contenido
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AdminHeader(),
                  const SizedBox(height: 24),
                  _buildTitle(),
                  const SizedBox(height: 24),
                  _buildGymNameSection(),
                  const SizedBox(height: 24),
                  _buildKeySection(),
                  const SizedBox(height: 24),
                  _buildActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Gestión de Clave del Gimnasio',
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _buildGymNameSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nombre del Gimnasio',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _gymNameController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Inter',
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Ej: Zikar, Boxing Club, etc.',
              hintStyle: TextStyle(color: Colors.white54),
            ),
            onChanged: (value) {
              // Actualizar el prefijo esperado en tiempo real
              if (value.length >= 3) {
                final prefix = value.toUpperCase().substring(0, 3);
                _updateExpectedPrefix(prefix);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKeySection() {
    return Consumer<AdminGymKeyCubit>(
      builder: (context, cubit, child) {
        if (cubit.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF0909)),
          );
        }

        if (cubit.hasError) {
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
                Text(
                  cubit.errorMessage ?? 'Error cargando clave',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => cubit.loadGymKey(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        return Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Clave del Gimnasio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                  if (!_isEditing)
                    IconButton(
                      onPressed: _startEdit,
                      icon: const Icon(Icons.edit, color: Colors.white),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (_isEditing) ...[
                TextField(
                  controller: _keyController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: _getExpectedPrefixHint(),
                    hintStyle: const TextStyle(color: Colors.white54),
                    suffixIcon: _buildPrefixIndicator(),
                  ),
                  maxLength: 20,
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 8),
                _buildFormatInfo(),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        cubit.gymKey ?? 'Sin clave',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _copyToClipboard(cubit.gymKey!),
                      icon: const Icon(Icons.copy, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () => _shareKey(cubit.gymKey!),
                      icon: const Icon(Icons.share, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrefixIndicator() {
    final gymName = _gymNameController.text.trim();
    if (gymName.length >= 3) {
      final prefix = gymName.toUpperCase().substring(0, 3);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFF0909),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          prefix,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildFormatInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.5)),
      ),
      child: const Text(
        'Formato: PRIMERAS_3_LETRAS + al menos 4 caracteres adicionales\n'
        'Ejemplo: "Zikar" → "ZIK23hk", "Boxing Club" → "BOX45mn"',
        style: TextStyle(color: Colors.blue, fontSize: 12, fontFamily: 'Inter'),
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        if (_isEditing) ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () => _saveKey(context),
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
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _cancelEdit,
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          // Botón generar nueva clave
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
      ],
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
    final gymName = _gymNameController.text.trim();
    if (gymName.isEmpty) {
      _showError('Primero ingresa el nombre del gimnasio');
      return;
    }

    if (gymName.length < 3) {
      _showError('El nombre del gimnasio debe tener al menos 3 caracteres');
      return;
    }

    final cubit = Provider.of<AdminGymKeyCubit>(context, listen: false);
    final newKey = cubit.generateNewKey(gymName);

    _keyController.text = newKey;
    setState(() {
      _isEditing = true;
    });
  }

  Future<void> _saveKey(BuildContext context) async {
    final newKey = _keyController.text.trim();
    final gymName = _gymNameController.text.trim();

    if (newKey.isEmpty) {
      _showError('La clave no puede estar vacía');
      return;
    }

    if (gymName.isEmpty) {
      _showError('El nombre del gimnasio no puede estar vacío');
      return;
    }

    // Validar nuevo formato: debe empezar con las 3 letras del gimnasio
    final cubit = Provider.of<AdminGymKeyCubit>(context, listen: false);
    if (!cubit.isValidKeyFormat(newKey, gymName)) {
      final expectedPrefix = cubit.getExpectedPrefix(gymName);
      _showError(
        'La clave debe empezar con "$expectedPrefix" y tener al menos 7 caracteres totales',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
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
    Clipboard.setData(
      ClipboardData(
        text:
            'Clave del Gimnasio CapBox: $key\n\nUsa esta clave para registrarte como entrenador o registrar nuevos boxeadores.',
      ),
    );
    _showSuccess('Información de la clave copiada al portapapeles');
  }

  void _updateExpectedPrefix(String prefix) {
    // Actualizar el hint del TextField
    setState(() {});
  }

  String _getExpectedPrefixHint() {
    final gymName = _gymNameController.text.trim();
    if (gymName.length >= 3) {
      final prefix = gymName.toUpperCase().substring(0, 3);
      return '$prefix... (mínimo 7 caracteres)';
    }
    return 'Ingresa el nombre del gimnasio primero';
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
}
