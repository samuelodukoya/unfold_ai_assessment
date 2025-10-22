import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/biometric_data.dart';
import '../models/journal_entry.dart';

class DataService {
  final Random _random = Random();

  Future<void> _simulateLatency() async {
    final delay = 700 + _random.nextInt(500);
    await Future.delayed(Duration(milliseconds: delay));
  }

  void _simulateFailure() {
    if (_random.nextInt(10) == 0) {
      throw Exception('Network error: Failed to fetch data');
    }
  }

  Future<List<BiometricData>> loadBiometricData() async {
    await _simulateLatency();
    _simulateFailure();

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/biometrics_90d.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => BiometricData.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load biometric data: $e');
    }
  }

  Future<List<JournalEntry>> loadJournalEntries() async {
    await _simulateLatency();
    _simulateFailure();

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/journals.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => JournalEntry.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load journal entries: $e');
    }
  }

  List<BiometricData> generateLargeDataset(int count) {
    final baseDate = DateTime(2023, 1, 1);
    final random = Random(42);

    return List.generate(count, (index) {
      return BiometricData(
        date: baseDate.add(Duration(hours: index)),
        hrv: 50 + random.nextDouble() * 20,
        rhr: 55 + random.nextInt(20),
        steps: 5000 + random.nextInt(5000),
        sleepScore: 60 + random.nextInt(40),
      );
    });
  }
}
