class BiometricData {
  final DateTime date;
  final double hrv;
  final int rhr;
  final int steps;
  final int sleepScore;

  BiometricData({
    required this.date,
    required this.hrv,
    required this.rhr,
    required this.steps,
    required this.sleepScore,
  });

  factory BiometricData.fromJson(Map<String, dynamic> json) {
    return BiometricData(
      date: DateTime.parse(json['date']),
      hrv: (json['hrv'] as num).toDouble(),
      rhr: json['rhr'] as int,
      steps: json['steps'] as int,
      sleepScore: json['sleepScore'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'hrv': hrv,
      'rhr': rhr,
      'steps': steps,
      'sleepScore': sleepScore,
    };
  }
}
