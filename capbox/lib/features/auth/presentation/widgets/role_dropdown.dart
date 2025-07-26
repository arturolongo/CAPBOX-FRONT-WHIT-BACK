import 'package:flutter/material.dart';

class RoleDropdown extends StatelessWidget {
  final String? value;
  final void Function(String?) onChanged;

  const RoleDropdown({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: Colors.black87,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          hint: const Text(
            'Elige tu rol',
            style: TextStyle(color: Colors.white70, fontFamily: 'Inter'),
          ),
          items: const [
            DropdownMenuItem(
              value: 'Entrenador',
              child: Text('Entrenador', style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
            ),
            DropdownMenuItem(
              value: 'Boxeador',
              child: Text('Boxeador', style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
            ),
            DropdownMenuItem(
              value: 'Administrador',
              child: Text('Administrador', style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}