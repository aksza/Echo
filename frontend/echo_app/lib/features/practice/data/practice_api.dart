import 'dart:io';

import 'package:dio/dio.dart';
import 'package:echo_app/core/network/dio_client.dart';
import 'package:echo_app/features/practice/data/practice_models.dart';

class PracticeApi {
  final Dio dio = DioClient().dio;

  Future<StartPracticeSessionResponse> startMistakePractice({
    required String token,
    int count = 5,
  }) async {
    final response = await dio.post(
      '/practice/mistakes/start',
      queryParameters: {
        'count': count,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return StartPracticeSessionResponse.fromJson(response.data);
  }

  Future<PracticeAnswerResponse> submitTextAnswer({
    required String token,
    required String sessionId,
    required String practiceItemId,
    required String answer,
  }) async {
    final response = await dio.post(
      '/practice/mistakes/text-answer',
      data: {
        'sessionId': sessionId,
        'practiceItemId': practiceItemId,
        'answer': answer,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return PracticeAnswerResponse.fromJson(response.data);
  }

  Future<PracticeAnswerResponse> submitVoiceAnswer({
    required String token,
    required String sessionId,
    required String practiceItemId,
    required File audioFile,
    String language = 'en',
  }) async {
    final formData = FormData.fromMap({
      'sessionId': sessionId,
      'practiceItemId': practiceItemId,
      'audioFile': await MultipartFile.fromFile(
        audioFile.path,
        filename: audioFile.path.split('/').last,
      ),
      'language': language,
    });

    final response = await dio.post(
      '/practice/mistakes/voice-answer',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return PracticeAnswerResponse.fromJson(response.data);
  }

  Future<PracticeAnswerResponse> skipMistake({
    required String token,
    required String sessionId,
    required String practiceItemId,
  }) async {
    final response = await dio.post(
      '/practice/mistakes/skip',
      data: {
        'sessionId': sessionId,
        'practiceItemId': practiceItemId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return PracticeAnswerResponse.fromJson(response.data);
  }

  Future<PracticeSummaryModel> endSession({
    required String token,
    required String sessionId,
  }) async {
    final response = await dio.post(
      '/practice/mistakes/end',
      data: {
        'sessionId': sessionId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return PracticeSummaryModel.fromJson(response.data);
  }

  Future<PracticeSummaryModel> getSummary({
    required String token,
    required String sessionId,
  }) async {
    final response = await dio.get(
      '/practice/mistakes/summary/$sessionId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return PracticeSummaryModel.fromJson(response.data);
  }
}