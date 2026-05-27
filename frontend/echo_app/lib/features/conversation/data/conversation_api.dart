import 'dart:io';

import 'package:dio/dio.dart';
import 'package:echo_app/core/network/dio_client.dart';
import 'voice_conversation_response.dart';

class ConversationApi {
  final Dio dio = DioClient().dio;

  Future<VoiceConversationResponse> sendVoiceMessage({
    required String token,
    required File audioFile,
    String? conversationId,
  }) async {
    final formData = FormData.fromMap({
      "audioFile": await MultipartFile.fromFile(
        audioFile.path,
        filename: "recording.wav",
      ),
      if (conversationId != null && conversationId.isNotEmpty)
        "conversationId": conversationId,
    });

    final response = await dio.post(
      "/conversation/voice-message",
      data: formData,
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
        contentType: "multipart/form-data",
      ),
    );

    print("VOICE RESPONSE: ${response.data}");

    return VoiceConversationResponse.fromJson(response.data);
  }
}