import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CoachNavBar extends StatelessWidget {
  final int currentIndex;

  const CoachNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.black,
      child: SizedBox(
        height: 60,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: currentIndex == 0 ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  if (currentIndex != 0) {
                    context.go('/coach-home');
                  }
                },
              ),
              const Text(
                'Inicio',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}