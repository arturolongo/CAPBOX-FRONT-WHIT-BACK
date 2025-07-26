import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../view_models/aws_register_cubit.dart';
import '../widgets/confirmation_code_form.dart';

class ResendCodePage extends StatefulWidget {
  const ResendCodePage({super.key});

  @override
  State<ResendCodePage> createState() => _ResendCodePageState();
}

class _ResendCodePageState extends State<ResendCodePage> {
  final TextEditingController _emailController = TextEditingController();
  bool _showCodeForm = false;
  String? _confirmedEmail;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.black.withOpacity(0.8)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 40),

                  if (!_showCodeForm) ...[
                    // Pantalla inicial: solicitar email
                    _buildEmailForm(),
                  ] else ...[
                    // Pantalla de confirmación: ingresar código
                    Text(
                      'Código enviado',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Se ha enviado un nuevo código de confirmación a:',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _confirmedEmail ?? '',
                      style: const TextStyle(
                        color: Color(0xFFFF0909),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    ConfirmationCodeForm(email: _confirmedEmail ?? ''),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Consumer<AWSRegisterCubit>(
      builder: (context, registerCubit, child) {
        return Column(
          children: [
            // Título
            const Text(
              'Reenviar código de confirmación',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Explicación
            Text(
              '¿No recibiste el código de confirmación?\nIngresa tu email para enviártelo nuevamente.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Campo de email
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
                decoration: const InputDecoration(
                  hintText: 'Correo electrónico',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  prefixIcon: Icon(Icons.email, color: Colors.white54),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botón reenviar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: registerCubit.isLoading ? null : _resendCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0909),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    registerCubit.isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Reenviar código',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 24),

            // Volver al login
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text(
                'Volver al inicio de sesión',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ),

            // Mostrar mensajes de error
            if (registerCubit.errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                ),
                child: Text(
                  registerCubit.errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _resendCode() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError('Por favor ingresa tu email');
      return;
    }

    if (!_isValidEmail(email)) {
      _showError('Por favor ingresa un email válido');
      return;
    }

    final registerCubit = context.read<AWSRegisterCubit>();

    print('🔄 REENVIANDO: Código de confirmación a $email');

    try {
      // Establecer el email pendiente antes de reenviar
      registerCubit.setPendingEmail(email);

      await registerCubit.resendConfirmationCode();

      // Si no hay error, mostrar formulario de código
      if (registerCubit.errorMessage == null) {
        setState(() {
          _showCodeForm = true;
          _confirmedEmail = email;
        });
        _showSuccess('Código enviado exitosamente');
      } else {
        _showError(registerCubit.errorMessage!);
      }
    } catch (e) {
      print('❌ ERROR REENVIANDO: $e');
      _showError('Error enviando código: $e');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
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
