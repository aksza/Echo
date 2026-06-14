import 'dart:io';

import 'package:echo_app/features/auth/presentation/auth_controller.dart';
import 'package:echo_app/features/conversation/data/conversation_api.dart';
import 'package:echo_app/features/conversation/data/conversation_message.dart';
import 'package:echo_app/features/conversation/data/voice_conversation_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversationState {
  final List<ConversationMessage> messages;
  final bool isLoading;

  ConversationState({
    required this.messages,
    required this.isLoading,
  });

  ConversationState copyWith({
    List<ConversationMessage>? messages,
    bool? isLoading,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final conversationApiProvider = Provider((ref) {
  return ConversationApi();
});

final conversationProvider =
    StateNotifierProvider<ConversationController, ConversationState>((ref) {
  return ConversationController(ref);
});

class ConversationController extends StateNotifier<ConversationState> {
  final Ref ref;

  String? conversationId;
  String? systemPrompt;

  ConversationController(this.ref)
      : super(
          ConversationState(
            messages: [],
            isLoading: false,
          ),
        );

  void startNewConversation({
    String? systemPrompt,
  }) {
    conversationId = null;
    this.systemPrompt = systemPrompt;

    state = ConversationState(
      messages: [],
      isLoading: false,
    );
  }

  Future<VoiceConversationResponse?> sendVoiceMessage(File audioFile) async {
    state = state.copyWith(isLoading: true);

    try {
      final api = ref.read(conversationApiProvider);
      final token = ref.read(authTokenProvider);

      if (token == null || token.isEmpty) {
        print("Missing auth token");
        state = state.copyWith(isLoading: false);
        return null;
      }

      final response = await api.sendVoiceMessage(
        audioFile: audioFile,
        token: token,
        conversationId: conversationId,
        systemPrompt: systemPrompt,
      );

      conversationId = response.conversationId;

      final updatedMessages = [
        ...state.messages,
        ConversationMessage(
          text: response.userTranscription,
          role: MessageRole.user,
        ),
        ConversationMessage(
          text: response.aiResponse,
          role: MessageRole.ai,
          audioUrl: response.audioUrl,
        ),
      ];

      state = state.copyWith(
        messages: updatedMessages,
        isLoading: false,
      );

      return response;
    } catch (e) {
      print("Conversation error: $e");

      state = state.copyWith(isLoading: false);

      return null;
    }
  }
}