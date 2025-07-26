import 'package:flutter/material.dart';

class CoachMetricsDetailedList extends StatelessWidget {
  const CoachMetricsDetailedList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> data = [
      {'prueba': 'Precisión', 'resultado': '8/20 golpes', 'calificacion': 6},
      {'prueba': 'Combo', 'resultado': '45 seg', 'calificacion': 2},
      {'prueba': 'Bloqueos', 'resultado': '5/15 bloqueos', 'calificacion': 7},
      {'prueba': 'Resistencia', 'resultado': '35s', 'calificacion': 1},
      {'prueba': 'Golpes/min', 'resultado': '85 golpes', 'calificacion': 10},
      {'prueba': 'Saltos', 'resultado': '60 saltos', 'calificacion': 9},
      {'prueba': 'Flexiones', 'resultado': '20 reps', 'calificacion': 4},
      {'prueba': 'Plancha', 'resultado': '40s', 'calificacion': 3},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          child: Row(
            children: const [
              Expanded(
                flex: 3,
                child: Text(
                  'Prueba',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Resultado',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Calificación',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ...data.map((item) => _metricRow(
              item['prueba'],
              item['resultado'],
              item['calificacion'],
            )),
      ],
    );
  }

  Widget _metricRow(String prueba, String resultado, int calificacion) {
    Color color = _getColor(calificacion);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                prueba,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                resultado,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              calificacion.toString(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  Color _getColor(int calificacion) {
    if (calificacion >= 8) {
      return Colors.green;
    } else if (calificacion >= 5) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}