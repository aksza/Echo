import 'package:echo_app/features/vocabulary/data/vocabulary_api.dart';
import 'package:echo_app/features/vocabulary/data/vocabulary_model.dart';

class VocabularyRepository {
  final VocabularyApi api;

  VocabularyRepository(this.api);

  Future<List<VocabularyModel>> getVocabularies({
    required String token,
  }) {
    return api.getVocabularies(token: token);
  }

  Future<VocabularyModel> addVocabulary({
    required String token,
    required String expression,
    required String translation,
    String? exampleSentence,
    int addedFrom = 0,
    int knowledgeLevel = 0,
  }) {
    return api.addVocabulary(
      token: token,
      expression: expression,
      translation: translation,
      exampleSentence: exampleSentence,
      addedFrom: addedFrom,
      knowledgeLevel: knowledgeLevel,
    );
  }

  Future<void> deleteVocabulary({
    required String token,
    required String vocabularyId,
  }) {
    return api.deleteVocabulary(
      token: token,
      vocabularyId: vocabularyId,
    );
  }

  Future<void> addPracticeHistory({
    required String token,
    required String vocabularyId,
    required bool success,
    int? responseTimeMs,
  }) {
    return api.addPracticeHistory(
      token: token,
      vocabularyId: vocabularyId,
      success: success,
      responseTimeMs: responseTimeMs,
    );
  }
}