import 'dart:io';

import 'package:echo_app/features/practice/data/practice_models.dart';
import 'package:echo_app/features/practice/presentation/practice_controller.dart';
import 'package:echo_app/features/practice/presentation/practice_summary_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class PracticePage extends ConsumerStatefulWidget {
  final int count;

  const PracticePage({
    super.key,
    this.count = 5,
  });

  @override
  ConsumerState<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends ConsumerState<PracticePage> {
  final TextEditingController answerController = TextEditingController();
  final AudioRecorder recorder = AudioRecorder();

  bool isRecording = false;
  File? recordedFile;
  bool hasOpenedSummary = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(practiceProvider.notifier).startSession(
            count: widget.count,
          );
    });
  }

  @override
  void dispose() {
    answerController.dispose();
    recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(practiceProvider, (previous, next) {
      final summary = next.summary;

      if (summary != null && !hasOpenedSummary) {
        hasOpenedSummary = true;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PracticeSummaryPage(
              summary: summary,
            ),
          ),
        );
      }
    });

    final state = ref.watch(practiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice mistakes'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: state.sessionId == null || state.isSubmitting
              ? null
              : () async {
                  await ref.read(practiceProvider.notifier).endSession();
                },
        ),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(PracticeState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return _ErrorView(
        message: state.errorMessage!,
        onRetry: () {
          ref.read(practiceProvider.notifier).startSession(
                count: widget.count,
              );
        },
      );
    }

    final item = state.currentItem;

    if (item == null) {
      return const Center(
        child: Text('No practice items available.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProgressHeader(
            current: state.displayIndex,
            total: state.items.length,
          ),
          const SizedBox(height: 20),
          _MistakePromptCard(item: item),
          const SizedBox(height: 20),
          _ModeSelector(
            mode: state.answerMode,
            onChanged: (mode) {
              ref.read(practiceProvider.notifier).setAnswerMode(mode);
            },
          ),
          const SizedBox(height: 20),
          if (state.lastAnswer == null)
            _AnswerInput(
              mode: state.answerMode,
              answerController: answerController,
              isSubmitting: state.isSubmitting,
              isRecording: isRecording,
              recordedFile: recordedFile,
              onSubmitText: () async {
                await ref
                    .read(practiceProvider.notifier)
                    .submitTextAnswer(answerController.text);
              },
              onStartRecording: startRecording,
              onStopRecording: stopRecording,
              onSubmitVoice: recordedFile == null
                  ? null
                  : () async {
                      await ref
                          .read(practiceProvider.notifier)
                          .submitVoiceAnswer(recordedFile!);
                    },
            ),
          if (state.lastAnswer != null)
            _ResultCard(
              result: state.lastAnswer!,
              hasNext: state.hasNextItem,
              onTryAgain: () {
                answerController.clear();
                recordedFile = null;

                ref.read(practiceProvider.notifier).retryCurrentItem();

                setState(() {});
              },
              onSkip: () async {
                answerController.clear();
                recordedFile = null;

                await ref.read(practiceProvider.notifier).skipCurrentItem();

                setState(() {});
              },
              onNext: () {
                answerController.clear();
                recordedFile = null;

                ref.read(practiceProvider.notifier).goToNextItem();

                setState(() {});
              },
              onFinish: () async {
                await ref.read(practiceProvider.notifier).endSession();
              },
            ),
          if (state.errorMessage != null && state.items.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
        ],
      ),
    );
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
        '${dir.path}/practice_answer_${DateTime.now().millisecondsSinceEpoch}.wav';

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
}

class _ProgressHeader extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressHeader({
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : current / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sentence $current of $total',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress),
      ],
    );
  }
}

class _MistakePromptCard extends StatelessWidget {
  final PracticeItemModel item;

  const _MistakePromptCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              avatar: const Icon(Icons.school),
              label: Text(
                item.category.isEmpty ? 'mistake' : item.category,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Correct this sentence:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.originalText,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            if (item.explanation != null &&
                item.explanation!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                item.explanation!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final PracticeAnswerMode mode;
  final ValueChanged<PracticeAnswerMode> onChanged;

  const _ModeSelector({
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PracticeAnswerMode>(
      segments: const [
        ButtonSegment(
          value: PracticeAnswerMode.text,
          label: Text('Text'),
          icon: Icon(Icons.keyboard),
        ),
        ButtonSegment(
          value: PracticeAnswerMode.voice,
          label: Text('Voice'),
          icon: Icon(Icons.mic),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
    );
  }
}

class _AnswerInput extends StatelessWidget {
  final PracticeAnswerMode mode;
  final TextEditingController answerController;
  final bool isSubmitting;
  final bool isRecording;
  final File? recordedFile;
  final VoidCallback onSubmitText;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback? onSubmitVoice;

  const _AnswerInput({
    required this.mode,
    required this.answerController,
    required this.isSubmitting,
    required this.isRecording,
    required this.recordedFile,
    required this.onSubmitText,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onSubmitVoice,
  });

  @override
  Widget build(BuildContext context) {
    if (mode == PracticeAnswerMode.text) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your correction',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: answerController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Write the corrected sentence...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSubmitting ? null : onSubmitText,
              icon: const Icon(Icons.check),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(isSubmitting ? 'Checking...' : 'Check answer'),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        Icon(
          isRecording ? Icons.mic : Icons.mic_none,
          size: 80,
          color: isRecording ? Colors.redAccent : Colors.grey,
        ),
        const SizedBox(height: 12),
        if (recordedFile != null)
          const Text(
            'Recording ready ✅',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isSubmitting
                ? null
                : isRecording
                    ? onStopRecording
                    : onStartRecording,
            icon: Icon(isRecording ? Icons.stop : Icons.mic),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                isRecording ? 'Stop recording' : 'Start recording',
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isSubmitting ? null : onSubmitVoice,
            icon: const Icon(Icons.upload),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(isSubmitting ? 'Checking...' : 'Submit voice answer'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final PracticeAnswerResponse result;
  final bool hasNext;
  final VoidCallback onTryAgain;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const _ResultCard({
    required this.result,
    required this.hasNext,
    required this.onTryAgain,
    required this.onSkip,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = result.isCorrect;

    return Card(
      color: isCorrect
          ? Colors.green.withOpacity(0.14)
          : Colors.redAccent.withOpacity(0.14),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              size: 72,
              color: isCorrect ? Colors.green : Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(
              isCorrect ? 'Correct!' : 'Not quite',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              result.feedback,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (result.transcribedAnswer != null &&
                result.transcribedAnswer!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              _InfoBox(
                title: 'Transcribed answer',
                text: result.transcribedAnswer!,
              ),
            ],
            if (!isCorrect) ...[
              const SizedBox(height: 16),
              _InfoBox(
                title: 'Correct answer',
                text: result.correctAnswer,
              ),
            ],
            const SizedBox(height: 24),
            if (isCorrect)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: hasNext ? onNext : onFinish,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(hasNext ? 'Next' : 'Finish'),
                  ),
                ),
              )
            else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTryAgain,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Try again'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onSkip,
                  child: const Text('Skip'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String text;

  const _InfoBox({
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(text),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not start practice.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}