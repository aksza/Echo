class MistakeModel {
  final String id;
  final String originalText;
  final String correctedText;
  final String? explanation;
  final String mistakeCategoryId;
  final String category;
  final String improvement;
  final DateTime createdAt;

  MistakeModel({
    required this.id,
    required this.originalText,
    required this.correctedText,
    required this.explanation,
    required this.mistakeCategoryId,
    required this.category,
    required this.improvement,
    required this.createdAt,
  });

  factory MistakeModel.fromJson(Map<String, dynamic> json) {
    return MistakeModel(
      id: json['id'] ?? '',
      originalText: json['originalText'] ?? '',
      correctedText: json['correctedText'] ?? '',
      explanation: json['explanation'],
      mistakeCategoryId: json['mistakeCategoryId'] ?? '',
      category: json['category'] ?? '',
      improvement: json['improvement'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}