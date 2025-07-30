import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:capbox/features/auth/presentation/view_models/aws_login_cubit.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  final Color redColor = const Color(0xFFFF0909);

  @override
  Widget build(BuildContext context) {
    final loginCubit = context.watch<AWSLoginCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTextField(
          controller: _emailController,
          hint: 'Correo electrónico',
          suffixIcon: const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          hint: 'Password',
          isPassword: true,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
        ),
        const SizedBox(height: 30),
        _buildLoginButton(loginCubit),
        const SizedBox(height: 16),
        _buildRegisterText(context),
        const SizedBox(height: 8),
        _buildResendCodeText(context),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required Widget suffixIcon,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword ? _obscureText : false,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(AWSLoginCubit loginCubit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: 181,
        height: 45,
        child: ElevatedButton(
          onPressed:
              loginCubit.isLoading
                  ? null
                  : () async {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();

                    if (!_validateEmail(email)) {
                      _showError('Correo electrónico no válido');
                      return;
                    }

                    if (!_validatePassword(password)) {
                      _showError(
                        'La contraseña debe tener al menos 6 caracteres, una mayúscula y un número',
                      );
                      return;
                    }

                    // LLAMADA REAL AL LOGIN
                    print('🚀 INICIANDO LOGIN...');
                    print('📧 Email: $email');

                    try {
                      await loginCubit.login(email, password);

                      if (loginCubit.isAuthenticated) {
                        // NUEVO FLUJO: Verificar si necesita activación antes de navegar
                        final route =
                            await loginCubit.getRouteWithActivationCheck();

                        print('✅ Login exitoso, navegando a: $route');
                        print('👤 Usuario: ${loginCubit.currentUser?.name}');
                        print('🎭 Rol: ${loginCubit.currentUser?.role}');

                        // Si necesita activación, pasar el rol como extra
                        if (route == '/gym-key-required') {
                          final userRole =
                              loginCubit.currentUser?.role
                                  .toString()
                                  .split('.')
                                  .last ??
                              'atleta';
                          print(
                            '🔑 LOGIN: Necesita clave, rol para activación: $userRole',
                          );
                          context.go(route, extra: userRole);
                        } else {
                          print(
                            '🏠 LOGIN: Navegando directamente a home: $route',
                          );
                          context.go(route);
                        }
                      } else if (loginCubit.errorMessage != null) {
                        print('❌ Login fallido: ${loginCubit.errorMessage}');
                        _showError(loginCubit.errorMessage!);
                      }
                    } catch (e) {
                      print('❌ Excepción en login: ${e.toString()}');
                      _showError('Error de conexión: ${e.toString()}');
                    }
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: redColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child:
              loginCubit.isLoading
                  ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildRegisterText(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/register'),
      child: const Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '¿No tienes cuenta? ',
              style: TextStyle(color: Color(0xFFFF0909), fontFamily: 'Inter'),
            ),
            TextSpan(
              text: 'Registrate',
              style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResendCodeText(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/resend-code'),
      child: const Text(
        '¿No recibiste el código de confirmación?',
        style: TextStyle(
          color: Colors.white70,
          fontFamily: 'Inter',
          fontSize: 14,
          decoration: TextDecoration.underline,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  bool _validateEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  bool _validatePassword(String password) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{6,}$');
    return regex.hasMatch(password);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
