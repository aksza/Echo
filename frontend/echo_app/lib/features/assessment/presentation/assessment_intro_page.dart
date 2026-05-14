import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echo_app/features/auth/presentation/registration_data_provider.dart';
import 'assessment_controller.dart';
import 'writing_assessment_page.dart';

class AssessmentIntroPage extends ConsumerWidget {
  const AssessmentIntroPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final helperQuestions = [
      "What do you usually talk about in English?",
      "Why do you want to improve your speaking?",
      "Where would you like to use English in real life?",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Level assessment")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Let's find your current level",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Echo mainly focuses on speaking practice. First, we will do a short writing task, then a speaking task.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              "You can think about:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...helperQuestions.map(
              (q) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text("• $q"),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  print('[AssessmentIntro] Starting assessment - resetting controllers');
                  // Reset assessment state before starting fresh assessment
                  ref.read(writingAssessmentProvider.notifier).reset();
                  ref.read(speakingAssessmentProvider.notifier).reset();
                  
                  print('[AssessmentIntro] Navigating to writing assessment');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WritingAssessmentPage(),
                    ),
                  );
                },
                child: const Text("Start assessment"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
