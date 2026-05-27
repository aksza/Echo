import 'package:echo_app/features/practice/data/practice_models.dart';
import 'package:echo_app/features/practice/presentation/practice_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PracticeSummaryPage extends ConsumerWidget {
  final PracticeSummaryModel summary;

  const PracticeSummaryPage({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice summary'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Icon(
              Icons.emoji_events,
              size: 90,
              color: Colors.amber,
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
              summary.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            _SummaryCard(summary: summary),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(practiceProvider.notifier).reset();

                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Back'),
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
  final PracticeSummaryModel summary;

  const _SummaryCard({
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _SummaryRow(
              label: 'Total items',
              value: summary.totalItems.toString(),
            ),
            const Divider(),
            _SummaryRow(
              label: 'Correct',
              value: summary.correctCount.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            const Divider(),
            _SummaryRow(
              label: 'Incorrect',
              value: summary.incorrectCount.toString(),
              icon: Icons.cancel,
              color: Colors.redAccent,
            ),
            const Divider(),
            _SummaryRow(
              label: 'Skipped',
              value: summary.skippedCount.toString(),
              icon: Icons.skip_next,
              color: Colors.orange,
            ),
            const Divider(),
            _SummaryRow(
              label: 'Accuracy',
              value: '${summary.accuracyPercent.toStringAsFixed(1)}%',
              icon: Icons.percent,
              color: Colors.blueAccent,
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
  final IconData? icon;
  final Color? color;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null)
          Icon(
            icon,
            color: color,
          ),
        if (icon != null) const SizedBox(width: 10),
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