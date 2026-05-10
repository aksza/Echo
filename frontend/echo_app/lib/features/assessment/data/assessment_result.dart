class AssessmentResult{
  final String level;
  final int score;
  final double confidence;
  final String feedback;

    AssessmentResult({
    required this.level,
    required this.score,
    required this.confidence,
    required this.feedback,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      level: _parseLevel(json["estimatedLevel"]),
      score: json["score"] ?? 0,
      confidence: (json["confidence"] ?? 0).toDouble(),
      feedback: json["feedback"] ?? "",
    );
  }

  static String _parseLevel(dynamic value) {
    if (value is String) {
      return value;
    }

    if (value is int) {
      return switch (value) {
        1 => "A1",
        2 => "A2",
        3 => "B1",
        4 => "B2",
        5 => "C1",
        6 => "C2",
        _ => "A1",
      };
    }

    return "A1";
  }
}