import '../models/biometric_data.dart';
import 'dart:math' as math;

class DecimationService {
  List<BiometricData> decimateLTTB(List<BiometricData> data, int threshold) {
    if (data.length <= threshold || threshold < 3) {
      return List.from(data);
    }

    final decimated = <BiometricData>[];

    decimated.add(data.first);

    final bucketSize = (data.length - 2) / (threshold - 2);

    int a = 0;

    for (int i = 0; i < threshold - 2; i++) {
      double avgX = 0;
      double avgY = 0;

      final avgRangeStart = math.min(
        ((i + 1) * bucketSize).floor() + 1,
        data.length - 1,
      );
      final avgRangeEnd = math.min(
        ((i + 2) * bucketSize).floor() + 1,
        data.length,
      );
      final avgRangeLength = avgRangeEnd - avgRangeStart;

      for (int j = avgRangeStart; j < avgRangeEnd; j++) {
        avgX += data[j].date.millisecondsSinceEpoch.toDouble();
        avgY += data[j].hrv;
      }
      avgX /= avgRangeLength;
      avgY /= avgRangeLength;

      final rangeOffs = ((i + 0) * bucketSize).floor() + 1;
      final rangeTo = ((i + 1) * bucketSize).floor() + 1;

      final pointAX = data[a].date.millisecondsSinceEpoch.toDouble();
      final pointAY = data[a].hrv;

      double maxArea = -1;
      int maxAreaPoint = rangeOffs;

      for (int j = rangeOffs; j < rangeTo && j < data.length; j++) {
        final pointX = data[j].date.millisecondsSinceEpoch.toDouble();
        final pointY = data[j].hrv;

        final area =
            ((pointAX - avgX) * (pointY - pointAY) -
                    (pointAX - pointX) * (avgY - pointAY))
                .abs() *
            0.5;

        if (area > maxArea) {
          maxArea = area;
          maxAreaPoint = j;
        }
      }

      decimated.add(data[maxAreaPoint]);
      a = maxAreaPoint;
    }

    decimated.add(data.last);

    return decimated;
  }

  List<BiometricData> decimateBucketMean(
    List<BiometricData> data,
    int threshold,
  ) {
    if (data.length <= threshold) {
      return List.from(data);
    }

    final decimated = <BiometricData>[];
    final bucketSize = data.length / threshold;

    for (int i = 0; i < threshold; i++) {
      final start = (i * bucketSize).floor();
      final end = math.min(((i + 1) * bucketSize).floor(), data.length);

      if (start >= data.length) break;

      double sumHrv = 0;
      double sumRhr = 0;
      double sumSteps = 0;
      double sumSleepScore = 0;
      final count = end - start;

      for (int j = start; j < end; j++) {
        sumHrv += data[j].hrv;
        sumRhr += data[j].rhr;
        sumSteps += data[j].steps;
        sumSleepScore += data[j].sleepScore;
      }

      final midIndex = start + (count ~/ 2);

      decimated.add(
        BiometricData(
          date: data[midIndex].date,
          hrv: sumHrv / count,
          rhr: (sumRhr / count).round(),
          steps: (sumSteps / count).round(),
          sleepScore: (sumSleepScore / count).round(),
        ),
      );
    }

    return decimated;
  }

  List<BiometricData> decimateMaxMinAvg(
    List<BiometricData> data,
    int threshold,
  ) {
    if (data.length <= threshold) {
      return List.from(data);
    }

    final decimated = <BiometricData>[];
    final bucketSize = data.length / (threshold / 3);

    for (int i = 0; i < threshold ~/ 3; i++) {
      final start = (i * bucketSize).floor();
      final end = math.min(((i + 1) * bucketSize).floor(), data.length);

      if (start >= data.length) break;

      BiometricData? minPoint;
      BiometricData? maxPoint;
      double sumHrv = 0;
      double sumRhr = 0;
      double sumSteps = 0;
      double sumSleepScore = 0;
      final count = end - start;

      for (int j = start; j < end; j++) {
        final point = data[j];
        sumHrv += point.hrv;
        sumRhr += point.rhr;
        sumSteps += point.steps;
        sumSleepScore += point.sleepScore;

        if (minPoint == null || point.hrv < minPoint.hrv) {
          minPoint = point;
        }
        if (maxPoint == null || point.hrv > maxPoint.hrv) {
          maxPoint = point;
        }
      }

      if (minPoint != null) decimated.add(minPoint);

      final midIndex = start + (count ~/ 2);
      decimated.add(
        BiometricData(
          date: data[midIndex].date,
          hrv: sumHrv / count,
          rhr: (sumRhr / count).round(),
          steps: (sumSteps / count).round(),
          sleepScore: (sumSleepScore / count).round(),
        ),
      );

      if (maxPoint != null && maxPoint != minPoint) {
        decimated.add(maxPoint);
      }
    }

    return decimated;
  }
}
