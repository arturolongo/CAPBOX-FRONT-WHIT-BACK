import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminNavBar extends StatelessWidget {
  final int currentIndex;
  const AdminNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.black,
      child: SizedBox(
        height: 60,
        child: Center(
          child: IconButton(
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
        ),
      ),
    );
  }
}