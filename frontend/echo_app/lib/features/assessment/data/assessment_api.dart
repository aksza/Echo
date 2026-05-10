import 'dart:io';
import 'package:dio/dio.dart';
import 'assessment_result.dart';

class AssessmentApi {
  final Dio dio;

  AssessmentApi(this.dio);

  Future<AssessmentResult> assessWriting({
    required String token,
    required String text,
  }) async {
    final response = await dio.post(
      '/assessment/text',
      data: {
        "text": text,
      },
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return AssessmentResult.fromJson(response.data);
  }

  Future<AssessmentResult> assessSpeaking({
    required String token,
    required File audioFile,
    String targetLanguage = "en",
  }) async {
    final formData = FormData.fromMap({
      "audioFile": await MultipartFile.fromFile(
        audioFile.path,
        filename: audioFile.path.split('/').last,
      ),
      "targetLanguage": targetLanguage,
    });

    final response = await dio.post(
      '/assessment/speaking',
      data: formData,
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "multipart/form-data",
        },
      ),
    );

    return AssessmentResult.fromJson(response.data);
  }
}