import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CoachRegisterPhysicalPage extends StatefulWidget {
  const CoachRegisterPhysicalPage({super.key});

  @override
  State<CoachRegisterPhysicalPage> createState() => _CoachRegisterPhysicalPageState();
}

class _CoachRegisterPhysicalPageState extends State<CoachRegisterPhysicalPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController alumnoController = TextEditingController(text: 'Juan Jimenez Ojendis');
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController estaturaController = TextEditingController();
  final TextEditingController edadDeportivaController = TextEditingController();
  final TextEditingController guardiaController = TextEditingController();
  final TextEditingController alergiasController = TextEditingController();
  final TextEditingController notasController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/fondo.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(color: Colors.black.withOpacity(0.6)),
          SafeArea(
            child: Column(
              children: [
                const CoachHeader(),
                const Divider(color: Color.fromARGB(255, 110, 110, 110)),
                const SizedBox(height: 8),
                const Text(
                  'Captura de datos de físicos de alumno',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          campoTexto('Alumno', alumnoController, enabled: false),
                          campoTexto(
                            'Peso',
                            pesoController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Campo requerido';
                              if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) return 'Solo números válidos';
                              return null;
                            },
                          ),
                          campoTexto(
                            'Estatura',
                            estaturaController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Campo requerido';
                              if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) return 'Solo números válidos';
                              return null;
                            },
                          ),
                          campoTexto('Edad deportiva', edadDeportivaController),
                          campoTexto('Guardia', guardiaController),
                          campoTexto('Alergias', alergiasController),
                          campoTexto(
                            'Notas',
                            notasController,
                            hintText: '(estas notas solo podrán ser vistas por el profesor)',
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.go('/coach-home');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Guardar datos', style: TextStyle(color: Colors.white)),
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
}