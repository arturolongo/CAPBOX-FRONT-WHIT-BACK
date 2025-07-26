import 'package:flutter/material.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:go_router/go_router.dart';

class CoachRegisterFightPage extends StatefulWidget {
  const CoachRegisterFightPage({super.key});

  @override
  State<CoachRegisterFightPage> createState() => _CoachRegisterFightPageState();
}

class _CoachRegisterFightPageState extends State<CoachRegisterFightPage> {
  final TextEditingController _eventController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _opponentNameController = TextEditingController();
  final TextEditingController _opponentAgeController = TextEditingController();
  final TextEditingController _opponentWeightController = TextEditingController();
  final TextEditingController _opponentGymController = TextEditingController();
  final TextEditingController _opponentGymLocationController = TextEditingController();
  final TextEditingController _observationsController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const CoachHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Registrar pelea', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      const Text('Alumno', style: TextStyle(color: Colors.red)),
                      _buildField('Juan Jimenez', enabled: false),
                      const SizedBox(height: 10),
                      _buildField('Nombre del evento', controller: _eventController),
                      _buildField('Lugar', controller: _placeController),
                      const SizedBox(height: 20),
                      const Text('Fecha', style: TextStyle(color: Colors.red)),
                      Row(
                        children: [
                          Expanded(child: _buildNumberField('Día', controller: _dayController, min: 1, max: 31)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildNumberField('Mes', controller: _monthController, min: 1, max: 12)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildNumberField('Año', controller: _yearController, min: 2020, max: 2100)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Datos del contrincante:', style: TextStyle(color: Colors.red)),
                      _buildField('Nombre', controller: _opponentNameController),
                      Row(
                        children: [
                          Expanded(child: _buildNumberField('Edad', controller: _opponentAgeController, min: 1, max: 99)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildNumberField('Peso en Kg', controller: _opponentWeightController, min: 1, max: 300)),
                        ],
                      ),
                      _buildField('Gimnasio', controller: _opponentGymController),
                      _buildField('Lugar del gimnasio', controller: _opponentGymLocationController),
                      const SizedBox(height: 20),
                      const Text('Observaciones:', style: TextStyle(color: Colors.red)),
                      _buildField('...', controller: _observationsController, maxLines: 5),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Simulamos guardar pelea y luego redirigimos
                              context.go('/coach/student-profile', extra: 'Juan Jimenez');
                            }
                          },
                          child: const Text('Registrar pelea'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CoachNavBar(currentIndex: 1),
    );
  }

  Widget _buildField(String hint, {TextEditingController? controller, int maxLines = 1, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        validator: (value) => (controller != null && value!.trim().isEmpty) ? 'Campo requerido' : null,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildNumberField(
    String hint, {
    required TextEditingController controller,
    required int min,
    required int max,
   }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo requerido';
        final number = int.tryParse(value);
        if (number == null || number < min || number > max) return 'Valor inválido';
        return null;
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}