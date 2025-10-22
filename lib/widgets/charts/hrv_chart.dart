import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/biometric_data.dart';
import '../../models/journal_entry.dart';
import '../../utils/theme.dart';
import '../../utils/statistics.dart';

class HrvChart extends StatelessWidget {
  final List<BiometricData> data;
  final List<JournalEntry> journals;
  final DateTime? selectedDate;
  final Function(DateTime?)? onDateSelected;
  final bool showBands;

  const HrvChart({
    super.key,
    required this.data,
    required this.journals,
    this.selectedDate,
    this.onDateSelected,
    this.showBands = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(child: Text('No data available')),
      );
    }

    final spots = data
        .map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.hrv))
        .toList();

    final minDate = data.first.date.millisecondsSinceEpoch.toDouble();
    final maxDate = data.last.date.millisecondsSinceEpoch.toDouble();
    final minHrv = data.map((d) => d.hrv).reduce((a, b) => a < b ? a : b) - 5;
    final maxHrv = data.map((d) => d.hrv).reduce((a, b) => a > b ? a : b) + 5;

    final lineBarsData = <LineChartBarData>[
      LineChartBarData(
        spots: spots,
        isCurved: true,
        color: AppTheme.hrvColor,
        barWidth: 3,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: AppTheme.hrvColor.withValues(alpha: 0.1),
        ),
      ),
    ];

    if (showBands && data.length >= 7) {
      final statsService = StatisticsService();
      final bands = statsService.calculateStatisticalBands(data, 7);

      final meanSpots = bands['mean']!
          .map((e) => FlSpot(e.key.millisecondsSinceEpoch.toDouble(), e.value))
          .toList();

      final upperSpots = bands['upper']!
          .map((e) => FlSpot(e.key.millisecondsSinceEpoch.toDouble(), e.value))
          .toList();

      final lowerSpots = bands['lower']!
          .map((e) => FlSpot(e.key.millisecondsSinceEpoch.toDouble(), e.value))
          .toList();

      lineBarsData.add(
        LineChartBarData(
          spots: meanSpots,
          isCurved: true,
          color: AppTheme.bandColor.withValues(alpha: 0.6),
          barWidth: 2,
          dotData: const FlDotData(show: false),
          dashArray: [5, 5],
        ),
      );

      lineBarsData.add(
        LineChartBarData(
          spots: upperSpots,
          isCurved: true,
          color: AppTheme.bandColor.withValues(alpha: 0.3),
          barWidth: 1,
          dotData: const FlDotData(show: false),
          dashArray: [3, 3],
        ),
      );

      lineBarsData.add(
        LineChartBarData(
          spots: lowerSpots,
          isCurved: true,
          color: AppTheme.bandColor.withValues(alpha: 0.3),
          barWidth: 1,
          dotData: const FlDotData(show: false),
          dashArray: [3, 3],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Heart Rate Variability (HRV)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showBands && data.length >= 7)
                  Text(
                    '7d mean ±1σ',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.bandColor),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minX: minDate,
                  maxX: maxDate,
                  minY: minHrv,
                  maxY: maxHrv,
                  lineBarsData: lineBarsData,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                            value.toInt(),
                          );
                          return Text(
                            '${date.month}/${date.day}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchCallback: (event, response) {
                      if (response?.lineBarSpots != null &&
                          response!.lineBarSpots!.isNotEmpty) {
                        final spot = response.lineBarSpots!.first;
                        final date = DateTime.fromMillisecondsSinceEpoch(
                          spot.x.toInt(),
                        );
                        onDateSelected?.call(date);
                      }
                    },
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                            spot.x.toInt(),
                          );
                          return LineTooltipItem(
                            '${date.month}/${date.day}\n${spot.y.toStringAsFixed(1)} ms',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
