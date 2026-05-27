import 'package:dio/dio.dart';
import 'package:echo_app/core/network/dio_client.dart';
import 'package:echo_app/features/vocabulary/data/vocabulary_model.dart';

class VocabularyApi {
  final Dio dio = DioClient().dio;

  Future<List<VocabularyModel>> getVocabularies({
    required String token,
  }) async {
    final response = await dio.get(
      '/vocabulary/vocabularies',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final data = response.data as List;

    return data
        .map((item) => VocabularyModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<VocabularyModel> addVocabulary({
    required String token,
    required String expression,
    required String translation,
    String? exampleSentence,
    int addedFrom = 0,
    int knowledgeLevel = 0,
  }) async {
    final response = await dio.post(
      '/vocabulary/add',
      data: {
        'expression': expression,
        'translation': translation,
        'exampleSentence': exampleSentence,
        'addedFrom': addedFrom,
        'knowledgeLevel': knowledgeLevel,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return VocabularyModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteVocabulary({
    required String token,
    required String vocabularyId,
  }) async {
    await dio.delete(
      '/vocabulary/$vocabularyId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}