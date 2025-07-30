import 'package:flutter/material.dart';
import 'package:capbox/features/auth/presentation/widgets/role_dropdown.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../view_models/aws_register_cubit.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  String? selectedRole;
  bool acceptTerms = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true; // NUEVO: Para confirmación

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController =
      TextEditingController(); // NUEVO: Controlador para confirmación
  final birthdateController = TextEditingController();
  final phoneController = TextEditingController();
  final gymNameController =
      TextEditingController(); // NUEVO: Para nombre del gimnasio

  final redColor = const Color(0xFFFF0909);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Registro',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'Rol',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          RoleDropdown(
            value: selectedRole,
            onChanged: (value) {
              setState(() {
                selectedRole = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // NUEVO FLUJO: No pedimos clave durante registro
          // La clave se solicitará después en el home
          if (selectedRole == 'Atleta' || selectedRole == 'Entrenador') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.5)),
              ),
              child: Text(
                selectedRole == 'Atleta'
                    ? '🎯 Después del registro te solicitaremos la clave del gimnasio'
                    : '🎯 Después del registro te solicitaremos la clave de entrenador',
                style: const TextStyle(
                  color: Colors.blue,
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (selectedRole == 'Admin') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: const Text(
                '👑 Como administrador, crearás tu propio gimnasio',
                style: TextStyle(
                  color: Colors.orange,
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (selectedRole != null) ...[
            const Text(
              'Datos personales',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              hint: 'Correo electrónico',
              icon: Icons.email,
              controller: emailController,
              inputType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              hint: 'Nombre',
              icon: Icons.person,
              controller: nameController,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              hint: 'Contraseña',
              icon: Icons.lock,
              isPassword: true,
              controller: passwordController,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              hint: 'Confirmar Contraseña',
              icon: Icons.lock,
              isPassword: true,
              controller: confirmPasswordController,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              hint: 'Fecha de nacimiento',
              icon: Icons.calendar_today,
              controller: birthdateController,
              readOnly: true,
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              hint: 'Número telefónico',
              icon: Icons.phone,
              controller: phoneController,
              inputType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            if (selectedRole == 'Admin') ...[
              const SizedBox(height: 12),
              const Text(
                'Nombre del Gimnasio',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                hint: 'Ej: Gimnasio Zikar, Boxing Club',
                icon: Icons.sports,
                controller: gymNameController,
                inputType: TextInputType.text,
              ),
            ],
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: acceptTerms,
                onChanged: (value) {
                  setState(() {
                    acceptTerms = value ?? false;
                  });
                },
                activeColor: redColor,
              ),
              const Expanded(
                child: Text(
                  'Acepto los términos y condiciones',
                  style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: Consumer<AWSRegisterCubit>(
              builder: (context, registerCubit, child) {
                return ElevatedButton(
                  onPressed:
                      registerCubit.isLoading
                          ? null
                          : () async {
                            print('🎯 BOTÓN REGISTRO PRESIONADO');

                            if (!acceptTerms) {
                              _showError(
                                'Debes aceptar los términos y condiciones',
                              );
                              return;
                            }
                            if (selectedRole == null) {
                              _showError('Debes seleccionar un rol');
                              return;
                            }
                            if (nameController.text.trim().isEmpty) {
                              _showError('El nombre no puede estar vacío');
                              return;
                            }
                            if (emailController.text.trim().isEmpty) {
                              _showError(
                                'El correo electrónico no puede estar vacío',
                              );
                              return;
                            }
                            if (!_validateEmail(emailController.text)) {
                              _showError('Correo electrónico no válido');
                              return;
                            }
                            if (passwordController.text.trim().isEmpty) {
                              _showError('La contraseña no puede estar vacía');
                              return;
                            }
                            if (confirmPasswordController.text.trim().isEmpty) {
                              _showError(
                                'La confirmación de contraseña no puede estar vacía',
                              );
                              return;
                            }
                            if (passwordController.text.trim() !=
                                confirmPasswordController.text.trim()) {
                              _showError('Las contraseñas no coinciden');
                              return;
                            }
                            if (!_validatePhone(phoneController.text)) {
                              _showError(
                                'El teléfono debe contener solo números y tener 10 dígitos',
                              );
                              return;
                            }
                            if (!_validatePassword(passwordController.text)) {
                              _showError(
                                'La contraseña debe tener al menos 8 caracteres, una mayúscula y un número',
                              );
                              return;
                            }

                            // Validar nombre del gimnasio para admins
                            if (selectedRole == 'Admin' &&
                                gymNameController.text.trim().isEmpty) {
                              _showError(
                                'El nombre del gimnasio no puede estar vacío',
                              );
                              return;
                            }

                            // NUEVO FLUJO: No validamos clave durante registro
                            // La clave se solicitará después en el home
                            // String claveGym = ''; // Se envía vacío siempre - REMOVIDO: No se usa

                            print('📋 INICIANDO REGISTRO CON DATOS:');
                            print('Email: ${emailController.text}');
                            print('Rol: $selectedRole');

                            // REGISTRAR CON EL CUBIT AWS CON NOMBRE GIMNASIO
                            await registerCubit.register(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                              fullName: nameController.text.trim(),
                              role: selectedRole!,
                              gymName:
                                  selectedRole == 'Admin'
                                      ? gymNameController.text.trim()
                                      : null,
                            );

                            // Manejar resultado según los estados de AWS
                            if (registerCubit.state ==
                                AWSRegisterState.success) {
                              _showSuccess(
                                registerCubit.successMessage ??
                                    'Usuario registrado exitosamente',
                              );
                              // Navegar al login después de 2 segundos
                              Future.delayed(Duration(seconds: 2), () {
                                if (context.mounted) {
                                  context.go('/');
                                }
                              });
                            } else if (registerCubit.state ==
                                AWSRegisterState.awaitingConfirmation) {
                              // Navegar inmediatamente a la pantalla de confirmación
                              print(
                                '🚀 NAVEGANDO A CONFIRMACIÓN PARA: ${emailController.text}',
                              );
                              context.go(
                                '/confirm-code',
                                extra: emailController.text.trim(),
                              );
                            } else if (registerCubit.errorMessage != null) {
                              _showError(registerCubit.errorMessage!);
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: redColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      registerCubit.isLoading
                          ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Registrar',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.pop(),
            child: const Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '¿Ya tienes cuenta? ',
                      style: TextStyle(
                        color: Color(0xFFFF0909),
                        fontFamily: 'Inter',
                      ),
                    ),
                    TextSpan(
                      text: 'Inicia sesión',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    bool isPassword = false,
    TextInputType? inputType,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    void Function()? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        obscureText:
            isPassword
                ? (hint == 'Confirmar Contraseña'
                    ? obscureConfirmPassword
                    : obscurePassword)
                : false,
        style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
        keyboardType: inputType,
        readOnly: readOnly,
        onTap: onTap,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.white),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      (hint == 'Confirmar Contraseña'
                              ? obscureConfirmPassword
                              : obscurePassword)
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        if (hint == 'Confirmar Contraseña') {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        } else {
                          obscurePassword = !obscurePassword;
                        }
                      });
                    },
                  )
                  : null,
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(primary: redColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      birthdateController.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  bool _validateEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  bool _validatePhone(String phone) {
    final regex = RegExp(r'^\d{10}$');
    return regex.hasMatch(phone);
  }

  bool _validatePassword(String password) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
    return regex.hasMatch(password);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
