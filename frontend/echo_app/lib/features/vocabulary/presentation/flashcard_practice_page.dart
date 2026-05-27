import 'package:echo_app/features/vocabulary/data/vocabulary_model.dart';
import 'package:echo_app/features/vocabulary/presentation/flashcard_summary_page.dart';
import 'package:flutter/material.dart';

class FlashcardPracticePage extends StatefulWidget {
  final List<VocabularyModel> vocabularyItems;

  const FlashcardPracticePage({
    super.key,
    required this.vocabularyItems,
  });

  @override
  State<FlashcardPracticePage> createState() => _FlashcardPracticePageState();
}

class _FlashcardPracticePageState extends State<FlashcardPracticePage> {
  final TextEditingController answerController = TextEditingController();

  int currentIndex = 0;
  int correctCount = 0;
  int incorrectCount = 0;
  int skippedCount = 0;

  bool isFlipped = false;
  bool? isCurrentAnswerCorrect;
  String? submittedAnswer;

  List<VocabularyModel> get items => widget.vocabularyItems;

  VocabularyModel get currentItem => items[currentIndex];

  bool get hasNext => currentIndex < items.length - 1;

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  void submitAnswer() {
    final answer = answerController.text.trim();

    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a translation.'),
        ),
      );
      return;
    }

    final correct = _normalize(answer) == _normalize(currentItem.translation);

    setState(() {
      isFlipped = true;
      isCurrentAnswerCorrect = correct;
      submittedAnswer = answer;

      if (correct) {
        correctCount++;
      } else {
        incorrectCount++;
      }
    });
  }

  void skipCurrentCard() {
    setState(() {
      skippedCount++;
    });

    if (hasNext) {
      goToNextCard();
    } else {
      finishPractice();
    }
  }

  void goToNextCard() {
    if (!hasNext) {
      finishPractice();
      return;
    }

    setState(() {
      currentIndex++;
      isFlipped = false;
      isCurrentAnswerCorrect = null;
      submittedAnswer = null;
      answerController.clear();
    });
  }

  void finishPractice() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardSummaryPage(
          totalCount: items.length,
          correctCount: correctCount,
          incorrectCount: incorrectCount,
          skippedCount: skippedCount,
        ),
      ),
    );
  }

  Future<void> closePractice() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exit practice?'),
          content: const Text(
            'Your current flashcard practice will end and a summary will be shown.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      finishPractice();
    }
  }

  String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll('!', '')
        .replaceAll('?', '')
        .replaceAll(';', '')
        .replaceAll(':', '');
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Flashcards'),
        ),
        body: const Center(
          child: Text('No vocabulary items available.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: closePractice,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _ProgressHeader(
              current: currentIndex + 1,
              total: items.length,
            ),
            const SizedBox(height: 24),
            _Flashcard(
              item: currentItem,
              isFlipped: isFlipped,
              submittedAnswer: submittedAnswer,
              isCorrect: isCurrentAnswerCorrect,
            ),
            const SizedBox(height: 24),
            if (!isFlipped)
              _AnswerInput(
                controller: answerController,
                onSubmit: submitAnswer,
                onSkip: skipCurrentCard,
              )
            else
              _AfterAnswerActions(
                hasNext: hasNext,
                isCorrect: isCurrentAnswerCorrect == true,
                onNext: goToNextCard,
                onFinish: finishPractice,
              ),
          ],
        ),
      ),
    );
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
          'Card $current of $total',
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

class _Flashcard extends StatelessWidget {
  final VocabularyModel item;
  final bool isFlipped;
  final String? submittedAnswer;
  final bool? isCorrect;

  const _Flashcard({
    required this.item,
    required this.isFlipped,
    required this.submittedAnswer,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: isFlipped
          ? _BackCard(
              key: const ValueKey('back'),
              item: item,
              submittedAnswer: submittedAnswer,
              isCorrect: isCorrect,
            )
          : _FrontCard(
              key: const ValueKey('front'),
              item: item,
            ),
    );
  }
}

class _FrontCard extends StatelessWidget {
  final VocabularyModel item;

  const _FrontCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 260),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.style,
              size: 48,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 24),
            const Text(
              'Translate this',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.expression,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (item.exampleSentence != null &&
                item.exampleSentence!.trim().isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                item.exampleSentence!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BackCard extends StatelessWidget {
  final VocabularyModel item;
  final String? submittedAnswer;
  final bool? isCorrect;

  const _BackCard({
    super.key,
    required this.item,
    required this.submittedAnswer,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final correct = isCorrect == true;

    return Card(
      elevation: 4,
      color: correct
          ? Colors.green.withOpacity(0.15)
          : Colors.redAccent.withOpacity(0.15),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 260),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              correct ? Icons.check_circle : Icons.cancel,
              size: 64,
              color: correct ? Colors.green : Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              correct ? 'Correct!' : 'Not quite',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _AnswerRow(
              label: 'Your answer',
              value: submittedAnswer ?? '',
            ),
            const SizedBox(height: 12),
            _AnswerRow(
              label: 'Correct answer',
              value: item.translation,
              highlight: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _AnswerRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
        border: highlight
            ? Border.all(
                color: Colors.green,
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 18 : 16,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onSkip;

  const _AnswerInput({
    required this.controller,
    required this.onSubmit,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your translation',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Write the translation...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onSubmit,
            icon: const Icon(Icons.check),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Submit'),
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
    );
  }
}

class _AfterAnswerActions extends StatelessWidget {
  final bool hasNext;
  final bool isCorrect;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const _AfterAnswerActions({
    required this.hasNext,
    required this.isCorrect,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isCorrect)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Review the correct answer before continuing.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasNext ? onNext : onFinish,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(hasNext ? 'Next card' : 'Finish'),
            ),
          ),
        ),
      ],
    );
  }
}