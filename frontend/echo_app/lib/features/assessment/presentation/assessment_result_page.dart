import 'package:echo_app/features/assessment/data/assessment_result.dart';
import 'package:echo_app/shared/app_shell.dart';
import 'package:flutter/material.dart';

class AssessmentResultPage extends StatelessWidget {
  final AssessmentResult writingResult;
  final AssessmentResult speakingResult;

  const AssessmentResultPage({
    super.key,
    required this.writingResult,
    required this.speakingResult,
  });

  @override
  Widget build(BuildContext context) {
    // Speaking-first app: the main displayed level is the speaking level.
    final level = speakingResult.level;

    return Scaffold(
      appBar: AppBar(title: const Text("Your level")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your estimated level is $level",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "This is based mainly on your speaking assessment.",
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 24),

            _ResultCard(
              title: "Speaking",
              level: speakingResult.level,
              score: speakingResult.score,
              confidence: speakingResult.confidence,
              feedback: speakingResult.feedback,
              isPrimary: true,
            ),

            const SizedBox(height: 16),

            _ResultCard(
              title: "Writing",
              level: writingResult.level,
              score: writingResult.score,
              confidence: writingResult.confidence,
              feedback: writingResult.feedback,
              isPrimary: false,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to AppShell (home) after assessment
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AppShell(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String level;
  final int score;
  final double confidence;
  final String feedback;
  final bool isPrimary;

  const _ResultCard({
    required this.title,
    required this.level,
    required this.score,
    required this.confidence,
    required this.feedback,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isPrimary ? 4 : 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isPrimary) ...[
                  const SizedBox(width: 8),
                  const Text("🎤"),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text("Level: $level"),
            Text("Score: $score/100"),
            Text("Confidence: ${(confidence * 100).round()}%"),
            const SizedBox(height: 8),
            Text(feedback),
          ],
        ),
      ),
    );
  }
}