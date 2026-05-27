import 'package:flutter/material.dart';

class FlashcardSummaryPage extends StatelessWidget {
  final int totalCount;
  final int correctCount;
  final int incorrectCount;
  final int skippedCount;

  const FlashcardSummaryPage({
    super.key,
    required this.totalCount,
    required this.correctCount,
    required this.incorrectCount,
    required this.skippedCount,
  });

  double get accuracy {
    final attempted = correctCount + incorrectCount;

    if (attempted == 0) {
      return 0;
    }

    return correctCount / attempted * 100;
  }

  String get message {
    if (totalCount == 0) {
      return 'No flashcards were practiced.';
    }

    if (accuracy >= 85) {
      return 'Excellent vocabulary practice!';
    }

    if (accuracy >= 60) {
      return 'Good progress. Keep reviewing these words.';
    }

    if (correctCount > 0) {
      return 'Nice start. Try these flashcards again later.';
    }

    return 'Keep practicing. Repetition will help.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard summary'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Icon(
              Icons.style,
              size: 90,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 24),
            const Text(
              'Practice complete!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            _SummaryCard(
              totalCount: totalCount,
              correctCount: correctCount,
              incorrectCount: incorrectCount,
              skippedCount: skippedCount,
              accuracy: accuracy,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Back to vocabulary'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int totalCount;
  final int correctCount;
  final int incorrectCount;
  final int skippedCount;
  final double accuracy;

  const _SummaryCard({
    required this.totalCount,
    required this.correctCount,
    required this.incorrectCount,
    required this.skippedCount,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _SummaryRow(
              label: 'Total cards',
              value: totalCount.toString(),
              icon: Icons.style,
              color: Colors.blueAccent,
            ),
            const Divider(),
            _SummaryRow(
              label: 'Correct',
              value: correctCount.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            const Divider(),
            _SummaryRow(
              label: 'Incorrect',
              value: incorrectCount.toString(),
              icon: Icons.cancel,
              color: Colors.redAccent,
            ),
            const Divider(),
            _SummaryRow(
              label: 'Skipped',
              value: skippedCount.toString(),
              icon: Icons.skip_next,
              color: Colors.orange,
            ),
            const Divider(),
            _SummaryRow(
              label: 'Accuracy',
              value: '${accuracy.toStringAsFixed(1)}%',
              icon: Icons.percent,
              color: Colors.purpleAccent,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}