import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echo_app/features/assessment/presentation/assessment_data_provider.dart';
import 'speaking_assessment_page.dart';

class WritingAssessmentPage extends ConsumerStatefulWidget {
  WritingAssessmentPage({super.key});

  @override
  ConsumerState<WritingAssessmentPage> createState() => _WritingAssessmentPageState();
}

class _WritingAssessmentPageState extends ConsumerState<WritingAssessmentPage> {
  late TextEditingController answerController;

  final helperQuestions = const [
    "Introduce yourself.",
    "What do you like doing in your free time?",
    "Why do you want to improve your English?",
    "Where would you like to use English?",
  ];

  @override
  void initState() {
    super.initState();
    answerController = TextEditingController();
    print('[WritingAssessment] initState - page loaded');
  }

  @override
  void dispose() {
    answerController.dispose();
    print('[WritingAssessment] dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('[WritingAssessment] BUILD() called');

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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitWriting,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text("Continue"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitWriting() async {
    print('[WritingAssessment] Submit button pressed');

    if (answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write something")),
      );
      return;
    }

    // Save writing text
    ref.read(assessmentDataProvider.notifier).setWritingText(answerController.text);
    print('[WritingAssessment] ✅ Writing text saved');

    // Navigate to speaking assessment
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const SpeakingAssessmentPage(),
      ),
    );
  }
}