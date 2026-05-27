class StartPracticeSessionResponse {
  final String sessionId;
  final int totalItems;
  final List<PracticeItemModel> items;

  StartPracticeSessionResponse({
    required this.sessionId,
    required this.totalItems,
    required this.items,
  });

  factory StartPracticeSessionResponse.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List? ?? [];

    return StartPracticeSessionResponse(
      sessionId: json['sessionId'] ?? '',
      totalItems: json['totalItems'] ?? 0,
      items: itemsJson
          .map((item) => PracticeItemModel.fromJson(item))
          .toList(),
    );
  }
}

class PracticeItemModel {
  final String practiceItemId;
  final String mistakeId;
  final String originalText;
  final String correctedText;
  final String? explanation;
  final String category;

  PracticeItemModel({
    required this.practiceItemId,
    required this.mistakeId,
    required this.originalText,
    required this.correctedText,
    required this.explanation,
    required this.category,
  });

  factory PracticeItemModel.fromJson(Map<String, dynamic> json) {
    return PracticeItemModel(
      practiceItemId: json['practiceItemId'] ?? '',
      mistakeId: json['mistakeId'] ?? '',
      originalText: json['originalText'] ?? '',
      correctedText: json['correctedText'] ?? '',
      explanation: json['explanation'],
      category: json['category'] ?? '',
    );
  }
}

class PracticeAnswerResponse {
  final String sessionId;
  final String practiceItemId;
  final bool isCorrect;
  final int score;
  final String feedback;
  final String correctAnswer;
  final String? userAnswer;
  final String? transcribedAnswer;
  final bool sessionCompleted;
  final PracticeSummaryModel? summary;

  PracticeAnswerResponse({
    required this.sessionId,
    required this.practiceItemId,
    required this.isCorrect,
    required this.score,
    required this.feedback,
    required this.correctAnswer,
    required this.userAnswer,
    required this.transcribedAnswer,
    required this.sessionCompleted,
    required this.summary,
  });

  factory PracticeAnswerResponse.fromJson(Map<String, dynamic> json) {
    return PracticeAnswerResponse(
      sessionId: json['sessionId'] ?? '',
      practiceItemId: json['practiceItemId'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      score: json['score'] ?? 0,
      feedback: json['feedback'] ?? '',
      correctAnswer: json['correctAnswer'] ?? '',
      userAnswer: json['userAnswer'],
      transcribedAnswer: json['transcribedAnswer'],
      sessionCompleted: json['sessionCompleted'] ?? false,
      summary: json['summary'] == null
          ? null
          : PracticeSummaryModel.fromJson(json['summary']),
    );
  }
}

class PracticeSummaryModel {
  final String sessionId;
  final int totalItems;
  final int correctCount;
  final int incorrectCount;
  final int skippedCount;
  final double accuracyPercent;
  final String message;
  final DateTime startedAt;
  final DateTime? endedAt;

  PracticeSummaryModel({
    required this.sessionId,
    required this.totalItems,
    required this.correctCount,
    required this.incorrectCount,
    required this.skippedCount,
    required this.accuracyPercent,
    required this.message,
    required this.startedAt,
    required this.endedAt,
  });

  factory PracticeSummaryModel.fromJson(Map<String, dynamic> json) {
    return PracticeSummaryModel(
      sessionId: json['sessionId'] ?? '',
      totalItems: json['totalItems'] ?? 0,
      correctCount: json['correctCount'] ?? 0,
      incorrectCount: json['incorrectCount'] ?? 0,
      skippedCount: json['skippedCount'] ?? 0,
      accuracyPercent: (json['accuracyPercent'] ?? 0).toDouble(),
      message: json['message'] ?? '',
      startedAt: DateTime.tryParse(json['startedAt'] ?? '') ?? DateTime.now(),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.tryParse(json['endedAt']),
    );
  }
}