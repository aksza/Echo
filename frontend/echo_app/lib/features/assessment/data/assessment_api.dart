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
    print('[AssessmentAPI] assessWriting called with text: "$text"');
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

    print('[AssessmentAPI] assessWriting response: ${response.data}');
    return AssessmentResult.fromJson(response.data);
  }

  Future<AssessmentResult> assessSpeaking({
    required String token,
    required File audioFile,
    String targetLanguage = "en",
  }) async {
    print('[AssessmentAPI] assessSpeaking called with file: ${audioFile.path}');
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

    print('[AssessmentAPI] assessSpeaking response: ${response.data}');
    return AssessmentResult.fromJson(response.data);
  }
}