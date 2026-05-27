import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:echo_app/features/conversation/data/conversation_message.dart';
import 'package:echo_app/features/conversation/presentation/conversation_controller.dart';
import 'package:echo_app/shared/widgets/selectable_ai_text.dart';
import 'package:echo_app/shared/widgets/selected_text_actions_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class ConversationPage extends ConsumerStatefulWidget {
  const ConversationPage({super.key});

  @override
  ConsumerState<ConversationPage> createState() =>
      _ConversationPageState();
}

class _ConversationPageState
    extends ConsumerState<ConversationPage> {
  final AudioRecorder recorder = AudioRecorder();
  final AudioPlayer player = AudioPlayer();
  final ScrollController scrollController = ScrollController();

  bool isRecording = false;
  File? recordedFile;

  @override
  void dispose() {
    recorder.dispose();
    player.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> startRecording() async {
    final hasPermission = await recorder.hasPermission();

    if (!hasPermission) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is required.'),
        ),
      );

      return;
    }

    final dir = await getTemporaryDirectory();

    final path =
        "${dir.path}/conversation_${DateTime.now().millisecondsSinceEpoch}.wav";

    await recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );

    setState(() {
      isRecording = true;
    });
  }

  Future<void> stopRecording() async {
    final path = await recorder.stop();

    setState(() {
      isRecording = false;
      recordedFile = path == null ? null : File(path);
    });

    if (recordedFile == null) return;

    final response = await ref
        .read(conversationProvider.notifier)
        .sendVoiceMessage(recordedFile!);

    if (response == null) return;

    print("AI TEXT: ${response.aiResponse}");
    print("AI AUDIO URL: ${response.audioUrl}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });

    if (response.audioUrl.isNotEmpty) {
      await player.play(
        UrlSource(response.audioUrl),
      );
    }
  }

  void scrollToBottom() {
    if (!scrollController.hasClients) return;

    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void openSelectedTextActions(String selectedText) {
    if (selectedText.trim().isEmpty) return;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        return SelectedTextActionsSheet(
          selectedText: selectedText.trim(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationProvider);

    final messages = state.messages;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Conversation"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                return _ConversationBubble(
                  message: message,
                  player: player,
                  onOpenSelectedTextActions: openSelectedTextActions,
                );
              },
            ),
          ),

          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: FloatingActionButton(
              onPressed:
                  state.isLoading ? null : isRecording ? stopRecording : startRecording,
              child: Icon(
                isRecording ? Icons.stop : Icons.mic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationBubble extends StatelessWidget {
  final ConversationMessage message;
  final AudioPlayer player;
  final void Function(String selectedText) onOpenSelectedTextActions;

  const _ConversationBubble({
    required this.message,
    required this.player,
    required this.onOpenSelectedTextActions,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(
          maxWidth: 330,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            if (isUser)
              Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                ),
              )
            else
              SelectableAiText(
                text: message.text,
                onOpenActions: onOpenSelectedTextActions,
              ),
            if (message.audioUrl != null &&
                message.audioUrl!.isNotEmpty) ...[
              const SizedBox(height: 8),
              IconButton(
                onPressed: () async {
                  await player.play(
                    UrlSource(message.audioUrl!),
                  );
                },
                icon: const Icon(
                  Icons.volume_up,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}