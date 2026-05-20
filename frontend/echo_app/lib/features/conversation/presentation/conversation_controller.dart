import 'dart:io';

import 'package:echo_app/features/auth/presentation/auth_controller.dart';
import 'package:echo_app/features/conversation/data/conversation_api.dart';
import 'package:echo_app/features/conversation/data/conversation_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final conversationApiProvider = Provider((ref) {
  return ConversationApi();
});

final conversationProvider = StateNotifierProvider<
    ConversationController,
    AsyncValue<List<ConversationMessage>>>((ref) {
  return ConversationController(ref);
});

class ConversationController
    extends StateNotifier<AsyncValue<List<ConversationMessage>>> {
  final Ref ref;

  String? conversationId;

  ConversationController(this.ref)
      : super(const AsyncValue.data([]));

  Future<void> sendVoiceMessage(File audioFile) async {
    final token = ref.read(authTokenProvider);

    if (token == null || token.isEmpty) {
      state = AsyncValue.error(
        "Missing auth token",
        StackTrace.current,
      );
      return;
    }

    final currentMessages = state.value ?? [];

    state = AsyncValue.loading();

    try {
      final api = ref.read(conversationApiProvider);

      final response = await api.sendVoiceMessage(
        token: token,
        audioFile: audioFile,
        conversationId: conversationId,
      );

      conversationId = response.conversationId;

      final updatedMessages = [
        ...currentMessages,
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

      state = AsyncValue.data(updatedMessages);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}