import 'package:flutter_test/flutter_test.dart';
import 'package:unfold_assessment/models/biometric_data.dart';
import 'package:unfold_assessment/services/decimation_service.dart';

void main() {
  group('DecimationService Tests', () {
    late DecimationService decimationService;

    setUp(() {
      decimationService = DecimationService();
    });

    test('LTTB decimation preserves min and max values', () {
      final testData = <BiometricData>[];
      final baseDate = DateTime(2025, 1, 1);

      for (int i = 0; i < 100; i++) {
        testData.add(
          BiometricData(
            date: baseDate.add(Duration(days: i)),
            hrv: 50 + (i % 20).toDouble(),
            rhr: 60,
            steps: 8000,
            sleepScore: 80,
          ),
        );
      }

      testData.add(
        BiometricData(
          date: baseDate.add(const Duration(days: 50)),
          hrv: 30,
          rhr: 60,
          steps: 8000,
          sleepScore: 80,
        ),
      );

      testData.add(
        BiometricData(
          date: baseDate.add(const Duration(days: 75)),
          hrv: 90,
          rhr: 60,
          steps: 8000,
          sleepScore: 80,
        ),
      );

      final decimated = decimationService.decimateLTTB(testData, 30);

      expect(decimated.length, lessThanOrEqualTo(30));
      expect(decimated.length, greaterThan(0));

      final originalMin = testData
          .map((d) => d.hrv)
          .reduce((a, b) => a < b ? a : b);
      final originalMax = testData
          .map((d) => d.hrv)
          .reduce((a, b) => a > b ? a : b);
      final decimatedMin = decimated
          .map((d) => d.hrv)
          .reduce((a, b) => a < b ? a : b);
      final decimatedMax = decimated
          .map((d) => d.hrv)
          .reduce((a, b) => a > b ? a : b);

      expect(decimatedMin, lessThanOrEqualTo(originalMin + 5));
      expect(decimatedMax, greaterThanOrEqualTo(originalMax - 5));

      expect(decimated.first.date, equals(testData.first.date));
      expect(decimated.last.date, equals(testData.last.date));
    });

    test('LTTB decimation produces correct output size', () {
      final testData = <BiometricData>[];
      final baseDate = DateTime(2025, 1, 1);

      for (int i = 0; i < 1000; i++) {
        testData.add(
          BiometricData(
            date: baseDate.add(Duration(hours: i)),
            hrv: 50 + (i % 30).toDouble(),
            rhr: 60,
            steps: 8000,
            sleepScore: 80,
          ),
        );
      }

      for (final threshold in [50, 100, 200, 500]) {
        final decimated = decimationService.decimateLTTB(testData, threshold);
        expect(decimated.length, lessThanOrEqualTo(threshold));
        expect(decimated.length, greaterThan(threshold ~/ 2));
      }
    });

    test('LTTB returns original data when threshold >= data length', () {
      final testData = <BiometricData>[];
      final baseDate = DateTime(2025, 1, 1);

      for (int i = 0; i < 50; i++) {
        testData.add(
          BiometricData(
            date: baseDate.add(Duration(days: i)),
            hrv: 55 + i.toDouble(),
            rhr: 60,
            steps: 8000,
            sleepScore: 80,
          ),
        );
      }

      final decimated = decimationService.decimateLTTB(testData, 100);
      expect(decimated.length, equals(testData.length));
    });

    test('Bucket mean decimation calculates correct averages', () {
      final testData = <BiometricData>[];
      final baseDate = DateTime(2025, 1, 1);

      for (int i = 0; i < 100; i++) {
        testData.add(
          BiometricData(
            date: baseDate.add(Duration(days: i)),
            hrv: 60,
            rhr: 60,
            steps: 8000,
            sleepScore: 80,
          ),
        );
      }

      final decimated = decimationService.decimateBucketMean(testData, 10);

      for (final point in decimated) {
        expect(point.hrv, closeTo(60, 0.5));
      }

      expect(decimated.length, lessThanOrEqualTo(10));
    });

    test('Max-Min-Avg decimation preserves extreme values', () {
      final testData = <BiometricData>[];
      final baseDate = DateTime(2025, 1, 1);

      for (int i = 0; i < 90; i++) {
        testData.add(
          BiometricData(
            date: baseDate.add(Duration(days: i)),
            hrv: 55,
            rhr: 60,
            steps: 8000,
            sleepScore: 80,
          ),
        );
      }

      testData.insert(
        45,
        BiometricData(
          date: baseDate.add(const Duration(days: 45)),
          hrv: 90,
          rhr: 60,
          steps: 8000,
          sleepScore: 80,
        ),
      );

      testData.insert(
        50,
        BiometricData(
          date: baseDate.add(const Duration(days: 50)),
          hrv: 30,
          rhr: 60,
          steps: 8000,
          sleepScore: 80,
        ),
      );

      final decimated = decimationService.decimateMaxMinAvg(testData, 30);

      final decimatedMin = decimated
          .map((d) => d.hrv)
          .reduce((a, b) => a < b ? a : b);
      final decimatedMax = decimated
          .map((d) => d.hrv)
          .reduce((a, b) => a > b ? a : b);

      expect(decimatedMin, equals(30));
      expect(decimatedMax, equals(90));
    });

    test('Decimation handles empty data gracefully', () {
      final emptyData = <BiometricData>[];

      expect(decimationService.decimateLTTB(emptyData, 10), isEmpty);
      expect(decimationService.decimateBucketMean(emptyData, 10), isEmpty);
      expect(decimationService.decimateMaxMinAvg(emptyData, 10), isEmpty);
    });

    test('Decimation handles single data point', () {
      final singlePoint = [
        BiometricData(
          date: DateTime(2025, 1, 1),
          hrv: 60,
          rhr: 60,
          steps: 8000,
          sleepScore: 80,
        ),
      ];

      final decimated = decimationService.decimateLTTB(singlePoint, 10);
      expect(decimated.length, equals(1));
      expect(decimated.first.hrv, equals(60));
    });
  });
}
