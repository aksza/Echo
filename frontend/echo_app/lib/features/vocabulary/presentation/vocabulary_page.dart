import 'package:echo_app/features/vocabulary/data/vocabulary_model.dart';
import 'package:echo_app/features/vocabulary/presentation/add_vocabulary_sheet.dart';
import 'package:echo_app/features/vocabulary/presentation/vocabulary_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VocabularyPage extends ConsumerWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabularyState = ref.watch(vocabularyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.read(vocabularyProvider.notifier).loadVocabulary();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            isScrollControlled: true,
            builder: (_) => const AddVocabularySheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: vocabularyState.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return _ErrorView(
            message: error.toString(),
            onRetry: () {
              ref.read(vocabularyProvider.notifier).loadVocabulary();
            },
          );
        },
        data: (items) {
          if (items.isEmpty) {
            return const _EmptyVocabularyView();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(vocabularyProvider.notifier).loadVocabulary();
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];

                return _VocabularyCard(
                  item: item,
                  onDelete: () async {
                    final shouldDelete = await _showDeleteDialog(context);

                    if (shouldDelete != true) return;

                    await ref
                        .read(vocabularyProvider.notifier)
                        .deleteVocabulary(item.id);

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vocabulary deleted.'),
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
          title: const Text('Delete vocabulary?'),
          content: const Text(
            'This word or expression will be removed from your vocabulary.',
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

String _formatAddedFrom(String value) {
  return switch (value.toLowerCase()) {
    '0' => 'Manual',
    '1' => 'Conversation',
    'manual' => 'Manual',
    'conversation' => 'Conversation',
    _ => value,
  };
}

class _VocabularyCard extends StatelessWidget {
  final VocabularyModel item;
  final VoidCallback onDelete;

  const _VocabularyCard({
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.expression,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.translation,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            if (item.exampleSentence != null &&
                item.exampleSentence!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.exampleSentence!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Chip(
                  avatar: const Icon(Icons.bookmark, size: 18),
                  label: Text(
                    _formatAddedFrom(item.addedFrom),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(item.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

class _EmptyVocabularyView extends StatelessWidget {
  const _EmptyVocabularyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No vocabulary yet. Add words manually or save selected words from AI conversations.',
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
              'Could not load vocabulary.',
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