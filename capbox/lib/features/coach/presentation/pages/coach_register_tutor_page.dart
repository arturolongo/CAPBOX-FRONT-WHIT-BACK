import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CoachRegisterTutorPage extends StatefulWidget {
  const CoachRegisterTutorPage({super.key});

  @override
  State<CoachRegisterTutorPage> createState() => _CoachRegisterTutorPageState();
}

class _CoachRegisterTutorPageState extends State<CoachRegisterTutorPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController alumnoController = TextEditingController(text: 'Juan Jimenez Ojendis');
  final TextEditingController nombresController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController parentescoController = TextEditingController();
  final TextEditingController telefono1Controller = TextEditingController();
  final TextEditingController telefono2Controller = TextEditingController();

  bool _isPhoneNumber(String value) => RegExp(r'^[0-9]+$').hasMatch(value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/fondo.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Container(
            color: Colors.black.withOpacity(0.6), 
          ),
          SafeArea(
            child: Column(
              children: [
                const CoachHeader(),
                const Divider(color: Color.fromARGB(255, 94, 94, 94)),
                const SizedBox(height: 8),
                const Text(
                  'Captura de datos de tutor',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          campoTexto('Alumno', alumnoController, enabled: false),
                          campoTexto('Nombres', nombresController),
                          campoTexto('Apellidos', apellidosController),
                          campoTexto('Parentesco', parentescoController),
                          campoTexto(
                            'Numero de telefono',
                            telefono1Controller,
                            keyboardType: TextInputType.phone,
                            validator: validarTelefono,
                          ),
                          campoTexto(
                            'Numero de telefono 2',
                            telefono2Controller,
                            keyboardType: TextInputType.phone,
                            hintText: 'Opcional',
                            validator: (value) {
                              if (value != null && value.isNotEmpty && !_isPhoneNumber(value)) {
                                return 'Solo se permiten números';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.go('/coach/register-physical'); 
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Siguiente', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                const CoachNavBar(currentIndex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget campoTexto(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(label, style: TextStyle(color: Colors.red[400])),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          validator: validator ?? (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
          decoration: InputDecoration(
            hintText: hintText ?? '',
            hintStyle: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
            filled: true,
            fillColor: Colors.black.withOpacity(0.4),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.purpleAccent),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  String? validarTelefono(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo requerido';
    } else if (!_isPhoneNumber(value)) {
      return 'Solo se permiten números';
    }
    return null;
  }
}