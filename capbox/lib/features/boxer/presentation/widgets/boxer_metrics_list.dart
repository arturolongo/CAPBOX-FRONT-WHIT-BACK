import 'package:flutter/material.dart';

class BoxerMetricsList extends StatelessWidget {
  const BoxerMetricsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: const [
              Expanded(
                child: Text(
                  'Atributo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '(0 - 10)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _metricRow('Resistencia', '8.9', Colors.green),
        const SizedBox(height: 10),
        _metricRow('Velocidad', '7.5', Colors.yellow),
        const SizedBox(height: 10),
        _metricRow('Técnica', '9', Colors.green),
        const SizedBox(height: 10),
        _metricRow('Fuerza', '5', Colors.red),
      ],
    );
  }

  Widget _metricRow(String attribute, String value, Color color) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              attribute,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}