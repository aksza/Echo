class LearningSummaryModel {
  final DateTime? accountCreatedAt;

  final int totalSessions;
  final int conversationSessions;
  final DateTime? lastSessionAt;

  final int vocabularyCount;
  final int vocabularyPracticeCount;
  final double vocabularyPracticeSuccessRate;

  final int mistakesCount;
  final int grammarMistakesCount;
  final int vocabularyMistakesCount;
  final int phrasingMistakesCount;
  final int sentenceStructureMistakesCount;

  final int practiceSessionsCount;
  final double lastMistakePracticeAccuracy;

  LearningSummaryModel({
    required this.accountCreatedAt,
    required this.totalSessions,
    required this.conversationSessions,
    required this.lastSessionAt,
    required this.vocabularyCount,
    required this.vocabularyPracticeCount,
    required this.vocabularyPracticeSuccessRate,
    required this.mistakesCount,
    required this.grammarMistakesCount,
    required this.vocabularyMistakesCount,
    required this.phrasingMistakesCount,
    required this.sentenceStructureMistakesCount,
    required this.practiceSessionsCount,
    required this.lastMistakePracticeAccuracy,
  });

  factory LearningSummaryModel.fromJson(Map<String, dynamic> json) {
    return LearningSummaryModel(
      accountCreatedAt: DateTime.tryParse(
        json['accountCreatedAt']?.toString() ?? '',
      ),
      totalSessions: _toInt(json['totalSessions']),
      conversationSessions: _toInt(json['conversationSessions']),
      lastSessionAt: DateTime.tryParse(
        json['lastSessionAt']?.toString() ?? '',
      ),
      vocabularyCount: _toInt(json['vocabularyCount']),
      vocabularyPracticeCount: _toInt(json['vocabularyPracticeCount']),
      vocabularyPracticeSuccessRate:
          _toDouble(json['vocabularyPracticeSuccessRate']),
      mistakesCount: _toInt(json['mistakesCount']),
      grammarMistakesCount: _toInt(json['grammarMistakesCount']),
      vocabularyMistakesCount: _toInt(json['vocabularyMistakesCount']),
      phrasingMistakesCount: _toInt(json['phrasingMistakesCount']),
      sentenceStructureMistakesCount:
          _toInt(json['sentenceStructureMistakesCount']),
      practiceSessionsCount: _toInt(json['practiceSessionsCount']),
      lastMistakePracticeAccuracy:
          _toDouble(json['lastMistakePracticeAccuracy']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }
}