import 'package:audioplayers/audioplayers.dart';
import 'package:echo_app/features/auth/presentation/auth_controller.dart';
import 'package:echo_app/features/conversation/data/selected_text_actions_api.dart';
import 'package:echo_app/features/conversation/presentation/conversation_page.dart';
import 'package:echo_app/features/lesson/data/research_lesson_content.dart';
import 'package:echo_app/shared/widgets/selectable_ai_text.dart';
import 'package:echo_app/shared/widgets/selected_text_actions_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LessonPage extends ConsumerStatefulWidget {
  const LessonPage({super.key});

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<LessonPage> {
  final SelectedTextActionsApi actionsApi = SelectedTextActionsApi();
  final AudioPlayer player = AudioPlayer();

  bool isSpeakingFullLesson = false;
  int? speakingSectionIndex;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  String? get token => ref.read(authTokenProvider);

  String get lessonSystemPrompt {
  final lesson = researchLesson;

  return """
  You are Echo, an AI English speaking partner for a research lesson.

  The learner is studying this lesson:
  ${lesson.title} - ${lesson.subtitle}

  The conversation topic is ONLY:
  - technology
  - online safety
  - malware
  - virus
  - worm
  - Trojan horse
  - ransomware
  - spyware
  - keystroke loggers
  - passwords
  - suspicious links
  - personal information
  - safe internet habits

  Important rules:
  - Only discuss the lesson topic.
  - Do not discuss unrelated topics.
  - If the learner changes topic, politely guide them back to online safety or malware.
  - Ask one short question at a time.
  - Use A2-B1 friendly English.
  - Keep your answers short.
  - Encourage the learner to speak.
  - Use vocabulary from the lesson when possible.
  - Ask follow-up questions to keep the conversation going.

  Useful lesson vocabulary:
  ${lesson.keyVocabulary.join(', ')}

  Example redirection:
  "Let's stay with online safety. What can happen if you click a suspicious link?"
  """;
  }

  Future<void> speakText({
    required String text,
    int? sectionIndex,
  }) async {
    if (token == null || token!.isEmpty) {
      showError('Missing authentication token.');
      return;
    }

    setState(() {
      if (sectionIndex == null) {
        isSpeakingFullLesson = true;
      } else {
        speakingSectionIndex = sectionIndex;
      }
    });

    try {
      final audioUrl = await actionsApi.speakText(
        token: token!,
        text: text,
        language: 'en',
      );

      if (audioUrl.isNotEmpty) {
        await player.play(UrlSource(audioUrl));
      }
    } catch (e) {
      showError(e.toString());
    } finally {
      if (!mounted) return;

      setState(() {
        if (sectionIndex == null) {
          isSpeakingFullLesson = false;
        } else {
          speakingSectionIndex = null;
        }
      });
    }
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

  void startConversation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationPage(
          lessonTitle: researchLesson.subtitle,
          initialSystemPrompt: lessonSystemPrompt,
        ),
      ),
    );
  }

  void showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = researchLesson;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Research Lesson'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LessonHeader(
              lesson: lesson,
              isSpeaking: isSpeakingFullLesson,
              onListen: () {
                speakText(
                  text: lesson.fullText,
                );
              },
              onStartConversation: startConversation,
            ),
            const SizedBox(height: 20),
            _KeyVocabularyCard(
              words: lesson.keyVocabulary,
              onOpenActions: openSelectedTextActions,
            ),
            const SizedBox(height: 20),
            const Text(
              'Lesson text',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(lesson.sections.length, (index) {
              final section = lesson.sections[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _LessonSectionCard(
                  section: section,
                  isSpeaking: speakingSectionIndex == index,
                  onListen: () {
                    speakText(
                      text: '${section.title}. ${section.text}',
                      sectionIndex: index,
                    );
                  },
                  onOpenActions: openSelectedTextActions,
                ),
              );
            }),
            const SizedBox(height: 12),
            _DiscussionQuestionsCard(
              questions: lesson.discussionQuestions,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: startConversation,
                icon: const Icon(Icons.mic),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Start AI conversation about this topic'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonHeader extends StatelessWidget {
  final ResearchLessonContent lesson;
  final bool isSpeaking;
  final VoidCallback onListen;
  final VoidCallback onStartConversation;

  const _LessonHeader({
    required this.lesson,
    required this.isSpeaking,
    required this.onListen,
    required this.onStartConversation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueAccent.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              lesson.subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              avatar: const Icon(Icons.school, size: 18),
              label: Text('Level: ${lesson.level}'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isSpeaking ? null : onListen,
                    icon: const Icon(Icons.volume_up),
                    label: Text(
                      isSpeaking ? 'Playing...' : 'Listen to lesson',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onStartConversation,
                    icon: const Icon(Icons.chat),
                    label: const Text('Talk'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyVocabularyCard extends StatelessWidget {
  final List<String> words;
  final void Function(String selectedText) onOpenActions;

  const _KeyVocabularyCard({
    required this.words,
    required this.onOpenActions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.menu_book, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Key vocabulary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: words.map((word) {
                return ActionChip(
                  label: Text(word),
                  avatar: const Icon(Icons.touch_app, size: 18),
                  onPressed: () {
                    onOpenActions(word);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonSectionCard extends StatelessWidget {
  final ResearchLessonSection section;
  final bool isSpeaking;
  final VoidCallback onListen;
  final void Function(String selectedText) onOpenActions;

  const _LessonSectionCard({
    required this.section,
    required this.isSpeaking,
    required this.onListen,
    required this.onOpenActions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    section.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Listen to this section',
                  onPressed: isSpeaking ? null : onListen,
                  icon: Icon(
                    isSpeaking ? Icons.hourglass_top : Icons.volume_up,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableAiText(
              text: section.text,
              onOpenActions: onOpenActions,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscussionQuestionsCard extends StatelessWidget {
  final List<String> questions;

  const _DiscussionQuestionsCard({
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.question_answer),
                SizedBox(width: 8),
                Text(
                  'Conversation questions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...questions.map((question) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Text(question),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}