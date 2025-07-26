import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CoachMetricsDetailedChart extends StatelessWidget {
  const CoachMetricsDetailedChart({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = {
      'precision': 7.5,
      'combo': 6.0,
      'bloqueos': 5.5,
      'resistencia': 8.0,
      'golpesMin': 4.5,
      'saltos': 6.2,
      'flexiones': 5.8,
      'plancha': 7.0,
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
              fillColor: Colors.red.withOpacity(0.4),
              borderColor: Colors.red,
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