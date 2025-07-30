import 'package:capbox/features/admin/presentation/widgets/admin_header.dart';
import 'package:capbox/features/admin/presentation/widgets/admin_navbar.dart';
import 'package:capbox/features/admin/presentation/widgets/admin_home_buttons.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AdminNavBar(currentIndex: 0),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/fondo.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AdminHeader(),
                  SizedBox(height: 24),
                  Divider(color: Color.fromARGB(255, 110, 109, 109)),
                  Text(
                    'Hola admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                  AdminHomeButtons(),
                  Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
