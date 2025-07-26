import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CoachEditStudentPage extends StatefulWidget {
  const CoachEditStudentPage({super.key});

  @override
  State<CoachEditStudentPage> createState() => _CoachEditStudentPageState();
}

class _CoachEditStudentPageState extends State<CoachEditStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  String nivelSeleccionado = 'Principiante';
  final List<String> niveles = ['Principiante', 'Intermedio', 'Avanzado', 'General'];

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
          Container(
            color: Colors.black.withOpacity(0.6), 
          ),
          SafeArea(
            child: Column(
              children: [
                const CoachHeader(),
                const Divider(color: Color.fromARGB(255, 110, 109, 109)),
                const SizedBox(height: 8),
                const Text(
                  'Captura de datos de alumno',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          campoTexto('Nombre', _nombreController),
                          campoTexto('Apellido', _apellidoController),
                          campoTexto('Fecha de nacimiento', _fechaController),
                          campoTexto('Edad', _edadController),
                          campoTexto(
                            'Correo electrónico',
                            _correoController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo requerido';
                              } else if (!value.contains('@')) {
                                return 'Debe ser un correo válido';
                              }
                              return null;
                            },
                            hintText: 'ejemplo@correo.com',
                          ),
                          campoTexto(
                            'Número de teléfono',
                            _telefonoController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo requerido';
                              } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Solo números';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Seleccionar nivel del alumno',
                              style: TextStyle(color: Colors.red[400]),
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            value: nivelSeleccionado,
                            dropdownColor: Colors.black87,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  nivelSeleccionado = value;
                                });
                              }
                            },
                            items: niveles.map((String nivel) {
                              return DropdownMenuItem<String>(
                                value: nivel,
                                child: Text(nivel),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.go('/coach/register-tutor');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400],
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Siguiente', style: TextStyle(color: Colors.white, fontSize: 16)),
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
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(label, style: TextStyle(color: Colors.red[400])),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          validator: validator ?? (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
          decoration: InputDecoration(
            hintText: hintText ?? '',
            hintStyle: const TextStyle(color: Colors.white54),
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