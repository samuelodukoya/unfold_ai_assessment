class JournalEntry {
  final DateTime date;
  final int mood;
  final String note;

  JournalEntry({required this.date, required this.mood, required this.note});

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      date: DateTime.parse(json['date']),
      mood: json['mood'] as int,
      note: json['note'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'mood': mood,
      'note': note,
    };
  }

  String get moodEmoji {
    switch (mood) {
      case 1:
        return '😢';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }
}
