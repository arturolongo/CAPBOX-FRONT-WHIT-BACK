import 'package:flutter/material.dart';

class BoxerTimerTable extends StatelessWidget {
  final List<Map<String, String>> exercises;

  const BoxerTimerTable({super.key, required this.exercises});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
        },
        border: TableBorder.symmetric(
          inside: const BorderSide(color: Colors.red, width: 0.5),
        ),
        children: [
          const TableRow(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('Ejercicio',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('Cantidad',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          ...exercises.map(
            (item) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(item['name'] ?? '',
                      style: const TextStyle(color: Colors.white70)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(item['count'] ?? '',
                      style: const TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
