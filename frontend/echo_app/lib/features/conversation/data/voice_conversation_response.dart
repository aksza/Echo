class VoiceConversationResponse {
  final String userTranscription;
  final String aiResponse;
  final String audioUrl;
  final String conversationId;

  VoiceConversationResponse({
    required this.userTranscription,
    required this.aiResponse,
    required this.audioUrl,
    required this.conversationId,
  });

  factory VoiceConversationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return VoiceConversationResponse(
      userTranscription: data['userTranscription'] ?? '',
      aiResponse: data['aiResponse'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      conversationId: data['conversationId'] ?? '',
    );
  }
}