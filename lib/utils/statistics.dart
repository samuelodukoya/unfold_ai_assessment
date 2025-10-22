import 'dart:math' as math;
import '../models/biometric_data.dart';

class StatisticsService {
  List<MapEntry<DateTime, double>> calculateRollingMean(
    List<BiometricData> data,
    int windowSize,
  ) {
    if (data.length < windowSize) {
      return [];
    }

    final result = <MapEntry<DateTime, double>>[];

    for (int i = windowSize - 1; i < data.length; i++) {
      double sum = 0;
      for (int j = i - windowSize + 1; j <= i; j++) {
        sum += data[j].hrv;
      }
      final mean = sum / windowSize;
      result.add(MapEntry(data[i].date, mean));
    }

    return result;
  }

  List<MapEntry<DateTime, double>> calculateRollingStdDev(
    List<BiometricData> data,
    int windowSize,
  ) {
    if (data.length < windowSize) {
      return [];
    }

    final result = <MapEntry<DateTime, double>>[];

    for (int i = windowSize - 1; i < data.length; i++) {
      double sum = 0;
      for (int j = i - windowSize + 1; j <= i; j++) {
        sum += data[j].hrv;
      }
      final mean = sum / windowSize;

      double varianceSum = 0;
      for (int j = i - windowSize + 1; j <= i; j++) {
        final diff = data[j].hrv - mean;
        varianceSum += diff * diff;
      }
      final stdDev = math.sqrt(varianceSum / windowSize);

      result.add(MapEntry(data[i].date, stdDev));
    }

    return result;
  }

  Map<String, List<MapEntry<DateTime, double>>> calculateStatisticalBands(
    List<BiometricData> data,
    int windowSize,
  ) {
    final means = calculateRollingMean(data, windowSize);
    final stdDevs = calculateRollingStdDev(data, windowSize);

    final upper = <MapEntry<DateTime, double>>[];
    final lower = <MapEntry<DateTime, double>>[];
    final meanLine = <MapEntry<DateTime, double>>[];

    for (int i = 0; i < means.length; i++) {
      final mean = means[i].value;
      final stdDev = stdDevs[i].value;
      final date = means[i].key;

      meanLine.add(MapEntry(date, mean));
      upper.add(MapEntry(date, mean + stdDev));
      lower.add(MapEntry(date, mean - stdDev));
    }

    return {'mean': meanLine, 'upper': upper, 'lower': lower};
  }

  Map<String, double> calculateBasicStats(List<double> values) {
    if (values.isEmpty) {
      return {'mean': 0, 'median': 0, 'min': 0, 'max': 0, 'stdDev': 0};
    }

    final sorted = List<double>.from(values)..sort();
    final mean = values.reduce((a, b) => a + b) / values.length;

    final median = sorted.length.isOdd
        ? sorted[sorted.length ~/ 2]
        : (sorted[sorted.length ~/ 2 - 1] + sorted[sorted.length ~/ 2]) / 2;

    final variance =
        values.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) /
        values.length;
    final stdDev = math.sqrt(variance);

    return {
      'mean': mean,
      'median': median,
      'min': sorted.first,
      'max': sorted.last,
      'stdDev': stdDev,
    };
  }
}
