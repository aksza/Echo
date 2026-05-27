import 'package:echo_app/features/mistakes/data/mistake_model.dart';
import 'package:echo_app/features/mistakes/presentation/mistake_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MistakeDetailPage extends ConsumerWidget {
  final String mistakeId;

  const MistakeDetailPage({
    super.key,
    required this.mistakeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mistakeState = ref.watch(
      mistakeDetailProvider(mistakeId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mistake details'),
        actions: [
          IconButton(
            onPressed: () async {
              final shouldDelete = await _showDeleteDialog(context);

              if (shouldDelete != true) return;

              final success = await ref
                  .read(mistakeDetailProvider(mistakeId).notifier)
                  .deleteMistake();

              if (!context.mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mistake deleted.'),
                  ),
                );

                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: mistakeState.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return _ErrorView(
            message: error.toString(),
            onRetry: () {
              ref
                  .read(mistakeDetailProvider(mistakeId).notifier)
                  .loadMistake();
            },
          );
        },
        data: (mistake) {
          if (mistake == null) {
            return const Center(
              child: Text('Mistake not found.'),
            );
          }

          return _MistakeDetailsContent(
            mistake: mistake,
          );
        },
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete mistake?'),
          content: const Text(
            'This mistake will be removed from your history.',
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _MistakeDetailsContent extends StatelessWidget {
  final MistakeModel mistake;

  const _MistakeDetailsContent({
    required this.mistake,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(
            avatar: const Icon(Icons.school),
            label: Text(
              mistake.category.isEmpty ? 'unknown' : mistake.category,
            ),
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'Original sentence',
            child: Text(
              mistake.originalText,
              style: const TextStyle(
                fontSize: 18,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Corrected sentence',
            child: Text(
              mistake.correctedText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Explanation',
            child: Text(
              mistake.explanation == null || mistake.explanation!.isEmpty
                  ? 'No explanation provided.'
                  : mistake.explanation!,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Improvement status',
            child: Text(
              mistake.improvement.isEmpty
                  ? 'Unknown'
                  : mistake.improvement,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Created at',
            child: Text(
              _formatDateTime(mistake.createdAt),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              child,
            ],
          ),
        ),
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
              size: 56,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load mistake.',
              style: TextStyle(
                fontSize: 18,
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