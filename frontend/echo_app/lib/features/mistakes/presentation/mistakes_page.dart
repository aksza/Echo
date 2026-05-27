import 'package:echo_app/features/mistakes/data/mistake_model.dart';
import 'package:echo_app/features/mistakes/presentation/mistake_controller.dart';
import 'package:echo_app/features/mistakes/presentation/mistake_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MistakesPage extends ConsumerWidget {
  const MistakesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mistakesState = ref.watch(mistakesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Mistakes'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(mistakesProvider.notifier).loadMistakes();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: mistakesState.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return _ErrorView(
            message: error.toString(),
            onRetry: () {
              ref.read(mistakesProvider.notifier).loadMistakes();
            },
          );
        },
        data: (mistakes) {
          if (mistakes.isEmpty) {
            return const _EmptyMistakesView();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(mistakesProvider.notifier).loadMistakes();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mistakes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final mistake = mistakes[index];

                return _MistakeCard(
                  mistake: mistake,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MistakeDetailPage(
                          mistakeId: mistake.id,
                        ),
                      ),
                    );

                    ref.read(mistakesProvider.notifier).loadMistakes();
                  },
                  onDelete: () async {
                    final shouldDelete = await _showDeleteDialog(context);

                    if (shouldDelete != true) return;

                    await ref
                        .read(mistakesProvider.notifier)
                        .deleteMistake(mistake.id);

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mistake deleted.'),
                      ),
                    );
                  },
                );
              },
            ),
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

class _MistakeCard extends StatelessWidget {
  final MistakeModel mistake;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MistakeCard({
    required this.mistake,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategoryBadge(category: mistake.category),
              const SizedBox(height: 12),
              const Text(
                'Original',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                mistake.originalText,
                style: const TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Corrected',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                mistake.correctedText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(mistake.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        category.isEmpty ? 'unknown' : category,
      ),
      avatar: const Icon(
        Icons.school,
        size: 18,
      ),
    );
  }
}

class _EmptyMistakesView extends StatelessWidget {
  const _EmptyMistakesView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No mistakes yet. Start a conversation and Echo will save your learning points here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
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
              'Could not load mistakes.',
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