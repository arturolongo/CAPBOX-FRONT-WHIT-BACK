import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BoxerMetricsChart extends StatelessWidget {
  const BoxerMetricsChart({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = {
      'Resistencia': 8.2,
      'Velocidad': 7.0,
      'Técnica': 8.5,
      'Fuerza': 5.0,
    };

    return SizedBox(
      height: 300,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          radarBackgroundColor: Colors.transparent,
          gridBorderData: const BorderSide(color: Colors.white24),
          tickBorderData: const BorderSide(color: Colors.white24),
          titlePositionPercentageOffset: 0.2,
          tickCount: 5,
          ticksTextStyle: const TextStyle(color: Colors.white70, fontSize: 10),
          dataSets: [
            RadarDataSet(
              fillColor: Colors.blue.withOpacity(0.4),
              borderColor: Colors.blue,
              entryRadius: 3,
              borderWidth: 2,
              dataEntries:
                  metrics.values.map((v) => RadarEntry(value: v)).toList(),
            ),
          ],
          getTitle: (index, _) {
            return RadarChartTitle(
              text: metrics.keys.elementAt(index),
            );
          },
        ),
        swapAnimationDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}