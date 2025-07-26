import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BoxerNavBar extends StatelessWidget {
  final int currentIndex;
  const BoxerNavBar({super.key, required this.currentIndex});

  void _onTap(BuildContext ctx, int index) {
    if (index == currentIndex) return;   

    switch (index) {
      case 0: ctx.go('/historial');   break;
      case 1: ctx.go('/boxer-home');  break;
      case 2: ctx.go('/perfil');      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.white,
      currentIndex: currentIndex,
      onTap: (i) => _onTap(context, i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
        BottomNavigationBarItem(icon: Icon(Icons.home),    label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.person),  label: 'Perfil'),
      ],
    );
  }
}