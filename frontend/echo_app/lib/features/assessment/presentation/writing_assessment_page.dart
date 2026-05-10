import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'assessment_controller.dart';
import 'speaking_assessment_page.dart';

class WritingAssessmentPage extends ConsumerWidget {
  WritingAssessmentPage({super.key});

  final answerController = TextEditingController();

  final helperQuestions = const [
    "Introduce yourself.",
    "What do you like doing in your free time?",
    "Why do you want to improve your English?",
    "Where would you like to use English?",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(writingAssessmentProvider);

    ref.listen(writingAssessmentProvider, (previous, next) {
      next.whenOrNull(
        data: (result) {
          if (result != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SpeakingAssessmentPage(
                  writingResult: result,
                ),
              ),
            );
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Writing assessment failed: $error")),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Writing assessment")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Write a short introduction in English",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text("Use these questions if you need ideas:"),
            const SizedBox(height: 8),
            ...helperQuestions.map(
              (q) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text("• $q"),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: answerController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: "Write here...",
                ),
              ),
            ),
            const SizedBox(height: 16),
            state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(writingAssessmentProvider.notifier)
                            .assessWriting(answerController.text);
                      },
                      child: const Text("Continue to speaking"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}