import 'package:dio/dio.dart';
import 'package:echo_app/core/network/dio_client.dart';

class SelectedTextActionsApi {
  final Dio dio = DioClient().dio;

  Future<String> speakText({
    required String token,
    required String text,
    String language = 'en',
  }) async {
    final response = await dio.post(
      '/conversation/speak-text',
      data: {
        'text': text,
        'language': language,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return response.data['audioUrl'] ?? '';
  }

  Future<String> translateText({
    required String token,
    required String text,
    String sourceLanguage = 'en',
    String targetLanguage = 'hu',
  }) async {
    final response = await dio.post(
      '/vocabulary/translate',
      data: {
        'text': text,
        'sourceLanguage': sourceLanguage,
        'targetLanguage': targetLanguage,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return response.data['translation'] ?? '';
  }

  Future<void> addToVocabulary({
    required String token,
    required String expression,
    required String translation,
    String? exampleSentence,
  }) async {
    await dio.post(
      '/vocabulary/add',
      data: {
        'expression': expression,
        'translation': translation,
        'exampleSentence': exampleSentence,

        // 1 = conversation, ha nálad az enum így van.
        // Ha nálad más sorrend van, ezt az enum alapján javítsuk.
        'addedFrom': 1,

        'knowledgeLevel': 0,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}