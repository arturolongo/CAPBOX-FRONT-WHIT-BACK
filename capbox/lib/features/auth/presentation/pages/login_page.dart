import 'package:flutter/material.dart';
import 'package:capbox/features/auth/presentation/widgets/login_form.dart';
import 'package:capbox/features/auth/presentation/widgets/login_header.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/fondo.png',
                fit: BoxFit.cover,
              ),
              Container(
                color: Colors.black.withOpacity(0.6),
              ),
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    LoginHeader(),
                    SizedBox(height: 30),
                    LoginForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
