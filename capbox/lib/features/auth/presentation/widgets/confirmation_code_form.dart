import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../view_models/aws_register_cubit.dart';

class ConfirmationCodeForm extends StatefulWidget {
  final String email;

  const ConfirmationCodeForm({super.key, required this.email});

  @override
  State<ConfirmationCodeForm> createState() => _ConfirmationCodeFormState();
}

class _ConfirmationCodeFormState extends State<ConfirmationCodeForm> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  final Color redColor = const Color(0xFFFF0909);

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AWSRegisterCubit>(
      builder: (context, registerCubit, child) {
        return Column(
          children: [
            // Instrucciones
            Text(
              'Ingresa el código de 6 dígitos que recibiste por email',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Campos de código
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => _buildCodeField(index)),
            ),

            const SizedBox(height: 32),

            // Botón confirmar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: registerCubit.isLoading ? null : _confirmCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: redColor,
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
                          'Confirmar cuenta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 24),

            // Reenviar código
            TextButton(
              onPressed: registerCubit.isLoading ? null : _resendCode,
              child: Text(
                '¿No recibiste el código? Reenviar',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Volver al registro
            TextButton(
              onPressed: () => context.go('/register'),
              child: const Text(
                'Volver al registro',
                style: TextStyle(
                  color: Color(0xFFFF0909),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ),

            // Mostrar mensajes de error o éxito
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

            if (registerCubit.successMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.5)),
                ),
                child: Text(
                  registerCubit.successMessage!,
                  style: const TextStyle(
                    color: Colors.green,
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

  Widget _buildCodeField(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Mover al siguiente campo
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              // Si es el último campo, quitar el foco
              _focusNodes[index].unfocus();
            }
          } else {
            // Si se borra, mover al campo anterior
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
        },
      ),
    );
  }

  void _confirmCode() async {
    final registerCubit = context.read<AWSRegisterCubit>();

    // Construir código de 6 dígitos
    final code = _controllers.map((c) => c.text).join();

    if (code.length != 6) {
      _showError('Por favor ingresa el código completo de 6 dígitos');
      return;
    }

    print('🔢 CONFIRMANDO CÓDIGO: $code');
    print('📧 EMAIL: ${widget.email}');

    try {
      await registerCubit.confirmRegistration(code);

      // Si la confirmación es exitosa, hacer login automático
      if (registerCubit.state == AWSRegisterState.success) {
        if (mounted) {
          _showSuccess('¡Cuenta confirmada exitosamente!');

          // REDIRIGIR AL LOGIN DESPUÉS DE CONFIRMACIÓN
          print(
            '🚀 CONFIRMACIÓN: Redirigiendo al login después de confirmación',
          );

          // Navegar al login después de 2 segundos
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              context.go('/');
            }
          });
        }
      }
    } catch (e) {
      print('❌ ERROR CONFIRMANDO CÓDIGO: $e');
      _showError('Error confirmando código: $e');
    }
  }

  void _resendCode() async {
    final registerCubit = context.read<AWSRegisterCubit>();

    print('🔄 REENVIANDO CÓDIGO A: ${widget.email}');

    try {
      await registerCubit.resendConfirmationCode();
      _showSuccess('Código reenviado exitosamente');
    } catch (e) {
      print('❌ ERROR REENVIANDO CÓDIGO: $e');
      _showError('Error reenviando código: $e');
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
