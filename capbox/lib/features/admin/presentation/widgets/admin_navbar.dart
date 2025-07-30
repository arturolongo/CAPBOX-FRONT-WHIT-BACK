import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capbox/features/auth/domain/entities/user.dart';

class AdminNavBar extends StatelessWidget {
  final int currentIndex;
  const AdminNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.black,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: currentIndex == 0 ? Colors.red : Colors.white,
              ),
              onPressed: () {
                if (currentIndex != 0) {
                  context.go('/admin-home');
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: currentIndex == 1 ? Colors.red : Colors.white,
              ),
              onPressed: () {
                if (currentIndex != 1) {
                  context.go(
                    '/profile',
                    extra: {'currentIndex': 1, 'role': UserRole.admin},
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
