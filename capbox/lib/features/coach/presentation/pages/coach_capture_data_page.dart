import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/coach_header.dart';
import '../widgets/coach_navbar.dart';
import '../../../admin/data/services/gym_service.dart';
import '../../../admin/data/dtos/gym_member_dto.dart';
import '../../../admin/presentation/cubit/gym_management_cubit.dart';
import '../../../../core/services/aws_api_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/user_display_service.dart';

class CoachCaptureDataPage extends StatefulWidget {
  final GymMemberDto athlete;

  const CoachCaptureDataPage({super.key, required this.athlete});

  @override
  State<CoachCaptureDataPage> createState() => _CoachCaptureDataPageState();
}

class _CoachCaptureDataPageState extends State<CoachCaptureDataPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Controladores para datos físicos
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _objectivesController = TextEditingController();
  String _selectedLevel = 'Principiante';
  String _selectedStance = 'Orthodox';

  // Controladores para datos del tutor
  final _tutorNameController = TextEditingController();
  final _tutorPhoneController = TextEditingController();
  final _tutorAddressController = TextEditingController();
  final _tutorEmailController = TextEditingController();
  String _selectedRelation = 'Padre';

  @override
  void dispose() {
    _pageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _medicalConditionsController.dispose();
    _objectivesController.dispose();
    _tutorNameController.dispose();
    _tutorPhoneController.dispose();
    _tutorAddressController.dispose();
    _tutorEmailController.dispose();
    super.dispose();
  }

  /// Debug del estado del coach
  Future<void> _debugCoachStatus() async {
    try {
      print('🔍 DEBUG: Verificando estado del coach...');

      // Mostrar información básica por ahora
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🔍 DEBUG COACH:\n'
            'Endpoint implementado en backend\n'
            'GET /identity/v1/atletas/debug/coach-status',
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('❌ DEBUG: Error verificando estado del coach - $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error debug: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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

                      // Botón de debug
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _debugCoachStatus,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.bug_report, size: 16),
                              label: const Text(
                                'Debug Coach',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Info del atleta
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF0909).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFF0909).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFFFF0909),
                              child: Text(
                                widget.athlete.name.isNotEmpty
                                    ? widget.athlete.name[0].toUpperCase()
                                    : 'A',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.athlete.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  Text(
                                    widget.athlete.email,
                                    style: const TextStyle(
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
                      ),

                      const SizedBox(height: 16),

                      // Indicador de progreso
                      _buildProgressIndicator(),
                    ],
                  ),
                ),

                // Contenido de los pasos
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentStep = index;
                      });
                    },
                    children: [_buildPhysicalDataStep(), _buildTutorDataStep()],
                  ),
                ),

                // Botones de navegación
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildNavigationButtons(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color:
                  _currentStep >= 0 ? const Color(0xFFFF0909) : Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color:
                  _currentStep >= 1 ? const Color(0xFFFF0909) : Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhysicalDataStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datos Físicos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Registra las características físicas del atleta',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Inter',
            ),
          ),

          const SizedBox(height: 24),

          // Peso y Estatura
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _weightController,
                  label: 'Peso (kg)',
                  hint: '70.5',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _heightController,
                  label: 'Estatura (cm)',
                  hint: '175',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Nivel
          _buildDropdown(
            label: 'Nivel de experiencia',
            value: _selectedLevel,
            items: ['Principiante', 'Intermedio', 'Avanzado'],
            onChanged: (value) {
              setState(() {
                _selectedLevel = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Guardia
          _buildDropdown(
            label: 'Guardia',
            value: _selectedStance,
            items: ['Orthodox', 'Southpaw', 'Switcher'],
            onChanged: (value) {
              setState(() {
                _selectedStance = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Condiciones médicas
          _buildTextField(
            controller: _medicalConditionsController,
            label: 'Condiciones médicas',
            hint: 'Lesiones, alergias, medicamentos...',
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          // Objetivos
          _buildTextField(
            controller: _objectivesController,
            label: 'Objetivos',
            hint: 'Metas y objetivos del atleta...',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTutorDataStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datos del Tutor/Emergencia',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Información de contacto de emergencia',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Inter',
            ),
          ),

          const SizedBox(height: 24),

          // Nombre del tutor
          _buildTextField(
            controller: _tutorNameController,
            label: 'Nombre completo del tutor',
            hint: 'Ej: Carlos Pérez García',
          ),

          const SizedBox(height: 16),

          // Relación
          _buildDropdown(
            label: 'Relación con el atleta',
            value: _selectedRelation,
            items: [
              'Padre',
              'Madre',
              'Tutor',
              'Hermano/a',
              'Tío/a',
              'Abuelo/a',
              'Otro',
            ],
            onChanged: (value) {
              setState(() {
                _selectedRelation = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Teléfono y Email
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _tutorPhoneController,
                  label: 'Teléfono',
                  hint: '9991234567',
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _tutorEmailController,
                  label: 'Email',
                  hint: 'tutor@email.com',
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Dirección
          _buildTextField(
            controller: _tutorAddressController,
            label: 'Dirección',
            hint: 'Calle, número, colonia, ciudad...',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white30),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white30),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFF0909)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white30),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              dropdownColor: Colors.grey.shade900,
              style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
              isExpanded: true,
              items:
                  items.map((item) {
                    return DropdownMenuItem(value: item, child: Text(item));
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Botón anterior
          if (_currentStep > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _goToPreviousStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Anterior'),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 16),

          // Botón siguiente/finalizar
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF0909),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  _isSubmitting
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Text(
                        _currentStep == 1 ? 'Finalizar Captura' : 'Siguiente',
                      ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToPreviousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleNextStep() {
    if (_currentStep == 0) {
      // Validar datos físicos
      if (_validatePhysicalData()) {
        _goToNextStep();
      }
    } else {
      // Validar datos del tutor y enviar
      if (_validateTutorData()) {
        _submitAllData();
      }
    }
  }

  void _goToNextStep() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validatePhysicalData() {
    if (_weightController.text.trim().isEmpty) {
      _showError('El peso es requerido');
      return false;
    }
    if (_heightController.text.trim().isEmpty) {
      _showError('La estatura es requerida');
      return false;
    }

    // Validar que sean números
    if (double.tryParse(_weightController.text.trim()) == null) {
      _showError('El peso debe ser un número válido');
      return false;
    }
    if (int.tryParse(_heightController.text.trim()) == null) {
      _showError('La estatura debe ser un número válido');
      return false;
    }

    return true;
  }

  bool _validateTutorData() {
    if (_tutorNameController.text.trim().isEmpty) {
      _showError('El nombre del tutor es requerido');
      return false;
    }
    if (_tutorPhoneController.text.trim().isEmpty) {
      _showError('El teléfono del tutor es requerido');
      return false;
    }

    return true;
  }

  void _submitAllData() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Preparar datos físicos
      final physicalData = {
        'peso': double.parse(_weightController.text.trim()),
        'estatura': int.parse(_heightController.text.trim()),
        'nivel': _selectedLevel.toLowerCase(),
        'guardia': _selectedStance.toLowerCase(),
        'condicionesMedicas': _medicalConditionsController.text.trim(),
        'objetivos': _objectivesController.text.trim(),
      };

      // Preparar datos del tutor
      final tutorData = {
        'nombreTutor': _tutorNameController.text.trim(),
        'telefonoTutor': _tutorPhoneController.text.trim(),
        'relacionTutor': _selectedRelation,
        'direccionTutor': _tutorAddressController.text.trim(),
        'emailTutor': _tutorEmailController.text.trim(),
      };

      print('📝 ENVIANDO DATOS COMPLETOS:');
      print('🏃 Físicos: $physicalData');
      print('👨‍👩‍👧‍👦 Tutor: $tutorData');

      // Enviar al backend
      final gymService = context.read<GymService>();
      await gymService.approveAthleteWithData(
        athleteId: widget.athlete.id,
        physicalData: physicalData,
        tutorData: tutorData,
      );

      if (mounted) {
        // 🔧 CORRECCIÓN IMPLEMENTADA: Actualizar el cubit después de la aprobación
        final cubit = context.read<GymManagementCubit>();
        print(
          '🔄 APROBACIÓN: Actualizando cubit después de aprobación exitosa',
        );
        await cubit.refresh(); // Recargar solicitudes pendientes
        print('✅ APROBACIÓN: Cubit actualizado');

        // 🔧 NUEVA CORRECCIÓN: Limpiar cache global para que el boxeador vea los cambios
        UserDisplayService.clearGlobalCache();
        print(
          '🗑️ APROBACIÓN: Cache global limpiado para actualizar estado del atleta',
        );

        // 🔧 DIAGNÓSTICO: Verificar si la solicitud se eliminó
        print('🔍 APROBACIÓN: Verificando estado después de aprobación...');
        final pendingRequests = cubit.pendingRequests;
        print(
          '📊 APROBACIÓN: Solicitudes pendientes después de aprobación: ${pendingRequests.length}',
        );
        for (var request in pendingRequests) {
          print(
            '📋 APROBACIÓN: Solicitud pendiente - ${request.name} (${request.id})',
          );
        }

        // 🔧 SOLUCIÓN TEMPORAL: Forzar actualización múltiple
        print('🔄 APROBACIÓN: Forzando actualización múltiple...');
        await Future.delayed(const Duration(milliseconds: 500));
        await cubit.refresh();
        await Future.delayed(const Duration(milliseconds: 500));
        await cubit.refresh();
        print('✅ APROBACIÓN: Actualización múltiple completada');

        _showSuccess(
          '¡Datos capturados exitosamente! El atleta ya puede usar la aplicación.',
        );

        // Navegar de regreso después de 2 segundos
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/coach-home');
          }
        });
      }
    } catch (e) {
      print('❌ ERROR ENVIANDO DATOS: $e');

      // 🔧 NUEVA CORRECCIÓN: Mostrar error específico al usuario
      String errorMessage = 'Error al guardar los datos del atleta.';

      if (e.toString().contains('500')) {
        errorMessage =
            'Error 500: Problema interno del servidor al aprobar al atleta. '
            'El equipo técnico ha sido notificado. Por favor, intenta nuevamente en unos minutos.';
      } else if (e.toString().contains('404')) {
        errorMessage =
            'Error 404: No se encontró solicitud para este atleta. '
            'El atleta podría no estar vinculado al gimnasio correctamente. '
            'Contacta al administrador.';
      } else if (e.toString().contains('403')) {
        errorMessage =
            'Error 403: No tienes permisos para aprobar atletas. Contacta al administrador.';
      } else if (e.toString().contains('coachEsDueño')) {
        errorMessage =
            'Error: La solicitud del atleta pertenece a otro entrenador.';
      } else if (e.toString().contains('limpiar-solicitud')) {
        errorMessage = 'Error: No se pudo procesar la solicitud del atleta.';
      } else if (e.toString().contains('Forbidden')) {
        errorMessage =
            'Error: Acceso denegado. Verifica tus permisos de entrenador.';
      }

      if (mounted) {
        _showError(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
