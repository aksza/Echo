enum MessageRole {
  user,
  ai,
}

class ConversationMessage {
  final String text;
  final MessageRole role;
  final String? audioUrl;

  ConversationMessage({
    required this.text,
    required this.role,
    this.audioUrl,
  });
}