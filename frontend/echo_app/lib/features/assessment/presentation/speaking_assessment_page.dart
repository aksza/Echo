import 'dart:io';

import 'package:echo_app/features/assessment/presentation/assessment_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'assessment_result_page.dart';

class SpeakingAssessmentPage extends ConsumerStatefulWidget {
  const SpeakingAssessmentPage({super.key});

  @override
  ConsumerState<SpeakingAssessmentPage> createState() =>
      _SpeakingAssessmentPageState();
}

class _SpeakingAssessmentPageState
    extends ConsumerState<SpeakingAssessmentPage> {
  final AudioRecorder recorder = AudioRecorder();

  bool isRecording = false;
  File? recordedFile;

  DateTime? recordingStartedAt;

  final helperQuestions = const [
    "Tell me about yourself.",
    "What are your hobbies?",
    "Why do you want to speak English better?",
    "Describe a place you would like to visit.",
  ];

  @override
  void initState() {
    super.initState();
    print('[SpeakingAssessment] initState - page loaded');
  }

  @override
  void dispose() {
    recorder.dispose();
    print('[SpeakingAssessment] dispose');
    super.dispose();
  }

  Future<void> startRecording() async {
    final hasPermission = await recorder.hasPermission();

    if (!hasPermission) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Microphone permission is required.",
          ),
        ),
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
      recordingStartedAt = DateTime.now();
    });

    print('[SpeakingAssessment] Recording started');
  }

  Future<void> stopRecording() async {
    if (recordingStartedAt != null) {
      final duration =
          DateTime.now().difference(recordingStartedAt!);

      if (duration.inSeconds < 3) {
        await recorder.stop();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please speak for at least 3 seconds.",
            ),
          ),
        );

        setState(() {
          isRecording = false;
          recordedFile = null;
        });

        return;
      }
    }

    final path = await recorder.stop();

    setState(() {
      isRecording = false;
      recordedFile = path == null ? null : File(path);
    });

    print('[SpeakingAssessment] Recording stopped: $path');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Speaking assessment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Record a short speaking answer",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
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
                isRecording
                    ? Icons.mic
                    : Icons.mic_none,
                size: 72,
                color: isRecording
                    ? Colors.redAccent
                    : Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            if (isRecording)
              const Center(
                child: Text(
                  "Recording...",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            if (recordedFile != null)
              const Center(
                child: Text(
                  "Recording ready ✅",
                ),
              ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isRecording
                        ? stopRecording
                        : startRecording,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  child: Text(
                    isRecording
                        ? "Stop recording"
                        : "Start recording",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    recordedFile == null
                        ? null
                        : _submitSpeaking,
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  child: Text("Continue"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitSpeaking() async {
    print('[SpeakingAssessment] Continue pressed');

    if (recordedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please record audio",
          ),
        ),
      );

      return;
    }

    final fileSize = await recordedFile!.length();

    if (fileSize <= 0) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Recorded audio file is empty.",
          ),
        ),
      );

      return;
    }

    ref
        .read(assessmentDataProvider.notifier)
        .setAudioFile(recordedFile);

    print('[SpeakingAssessment] ✅ Audio file saved');

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AssessmentResultPage(),
      ),
    );
  }
}