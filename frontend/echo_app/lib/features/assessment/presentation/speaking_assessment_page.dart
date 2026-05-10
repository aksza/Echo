import 'dart:io';
import 'package:echo_app/features/assessment/data/assessment_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'assessment_controller.dart';
import 'assessment_result_page.dart';

class SpeakingAssessmentPage extends ConsumerStatefulWidget {
  final AssessmentResult writingResult;

  const SpeakingAssessmentPage({
    super.key,
    required this.writingResult,
  });

  @override
  ConsumerState<SpeakingAssessmentPage> createState() =>
      _SpeakingAssessmentPageState();
}

class _SpeakingAssessmentPageState
    extends ConsumerState<SpeakingAssessmentPage> {
  final AudioRecorder recorder = AudioRecorder();
  bool isRecording = false;
  File? recordedFile;

  final helperQuestions = const [
    "Tell me about yourself.",
    "What are your hobbies?",
    "Why do you want to speak English better?",
    "Describe a place you would like to visit.",
  ];

  @override
  void dispose() {
    recorder.dispose();
    super.dispose();
  }

  Future<void> startRecording() async {
    final hasPermission = await recorder.hasPermission();

    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Microphone permission is required.")),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        "${dir.path}/speaking_assessment_${DateTime.now().millisecondsSinceEpoch}.wav";

    await recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
        echoCancel: true,
        noiseSuppress: true,
      ),
      path: path,
    );

    setState(() {
      isRecording = true;
      recordedFile = null;
    });
  }

  Future<void> stopRecording() async {
    final path = await recorder.stop();

    setState(() {
      isRecording = false;
      recordedFile = path == null ? null : File(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(speakingAssessmentProvider);

    ref.listen(speakingAssessmentProvider, (previous, next) {
      next.whenOrNull(
        data: (speakingResult) {
          if (speakingResult != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AssessmentResultPage(
                  writingResult: widget.writingResult,
                  speakingResult: speakingResult,
                ),
              ),
            );
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Speaking assessment failed: $error")),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Speaking assessment")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Record a short speaking answer",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Speak for around 20–40 seconds. You can answer one or more of these:",
            ),
            const SizedBox(height: 8),
            ...helperQuestions.map(
              (q) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text("• $q"),
              ),
            ),
            const Spacer(),
            Center(
              child: Icon(
                isRecording ? Icons.mic : Icons.mic_none,
                size: 72,
                color: isRecording ? Colors.redAccent : Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (recordedFile != null)
              const Center(child: Text("Recording ready ✅")),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : isRecording
                        ? stopRecording
                        : startRecording,
                child: Text(isRecording ? "Stop recording" : "Start recording"),
              ),
            ),
            const SizedBox(height: 12),
            state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: recordedFile == null
                          ? null
                          : () {
                              ref
                                  .read(speakingAssessmentProvider.notifier)
                                  .assessSpeaking(recordedFile!);
                            },
                      child: const Text("Finish assessment"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}