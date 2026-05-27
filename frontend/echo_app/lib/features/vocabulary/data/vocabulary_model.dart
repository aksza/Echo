class VocabularyModel {
  final String id;
  final String expression;
  final String translation;
  final String? exampleSentence;
  final String addedFrom;
  final DateTime createdAt;

  VocabularyModel({
    required this.id,
    required this.expression,
    required this.translation,
    required this.exampleSentence,
    required this.addedFrom,
    required this.createdAt,
  });

  factory VocabularyModel.fromJson(Map<String, dynamic> json) {
    return VocabularyModel(
      id: json['id']?.toString() ?? '',
      expression: json['expression'] ?? '',
      translation: json['translation'] ?? '',
      exampleSentence: json['exampleSentence'],
      addedFrom: json['addedFrom']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}