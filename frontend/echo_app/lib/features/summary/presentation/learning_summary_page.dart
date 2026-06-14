import 'package:echo_app/features/summary/data/learning_summary_model.dart';
import 'package:echo_app/features/summary/presentation/learning_summary_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LearningSummaryPage extends ConsumerWidget {
  const LearningSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryState = ref.watch(learningSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Summary'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.read(learningSummaryProvider.notifier).loadSummary();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: summaryState.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return _ErrorView(
            message: error.toString(),
            onRetry: () {
              ref.read(learningSummaryProvider.notifier).loadSummary();
            },
          );
        },
        data: (summary) {
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(learningSummaryProvider.notifier).loadSummary();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderCard(summary: summary),
                  const SizedBox(height: 20),
                  const Text(
                    'Learning activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StatsGrid(
                    cards: [
                      _StatCardData(
                        title: 'Sessions',
                        value: summary.totalSessions.toString(),
                        subtitle: 'total learning sessions',
                        icon: Icons.history,
                      ),
                      _StatCardData(
                        title: 'Conversations',
                        value: summary.conversationSessions.toString(),
                        subtitle: 'AI speaking sessions',
                        icon: Icons.mic,
                      ),
                      _StatCardData(
                        title: 'Vocabulary',
                        value: summary.vocabularyCount.toString(),
                        subtitle: 'saved words',
                        icon: Icons.menu_book,
                      ),
                      _StatCardData(
                        title: 'Mistakes',
                        value: summary.mistakesCount.toString(),
                        subtitle: 'detected mistakes',
                        icon: Icons.error_outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Vocabulary practice',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _WideStatCard(
                    title: 'Vocabulary attempts',
                    value: summary.vocabularyPracticeCount.toString(),
                    subtitle: 'flashcard answers submitted',
                    icon: Icons.style,
                  ),
                  const SizedBox(height: 10),
                  _ProgressSummaryCard(
                    title: 'Vocabulary success rate',
                    value: summary.vocabularyPracticeSuccessRate,
                    emptyText: 'No vocabulary practice yet.',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Mistake categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MistakeCategoryCard(summary: summary),
                  const SizedBox(height: 24),
                  const Text(
                    'Mistake practice',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _WideStatCard(
                    title: 'Practice sessions',
                    value: summary.practiceSessionsCount.toString(),
                    subtitle: 'mistake practice sessions completed',
                    icon: Icons.play_circle,
                  ),
                  const SizedBox(height: 10),
                  _ProgressSummaryCard(
                    title: 'Last mistake practice accuracy',
                    value: summary.lastMistakePracticeAccuracy,
                    emptyText: 'No mistake practice session yet.',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final LearningSummaryModel summary;

  const _HeaderCard({
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueAccent.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 8),
                Text(
                  'Learning profile',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _InfoRow(
              label: 'Account created',
              value: _formatDate(summary.accountCreatedAt),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Last session',
              value: _formatDate(summary.lastSessionAt),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final List<_StatCardData> cards;

  const _StatsGrid({
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _SmallStatCard(data: cards[0])),
            const SizedBox(width: 12),
            Expanded(child: _SmallStatCard(data: cards[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _SmallStatCard(data: cards[2])),
            const SizedBox(width: 12),
            Expanded(child: _SmallStatCard(data: cards[3])),
          ],
        ),
      ],
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final _StatCardData data;

  const _SmallStatCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(data.icon, size: 28),
            const SizedBox(height: 10),
            Text(
              data.title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              data.subtitle,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WideStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _WideStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ProgressSummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final String emptyText;

  const _ProgressSummaryCard({
    required this.title,
    required this.value,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value > 0;
    final progress = (value / 100).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: hasValue
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 8),
                  Text('${value.toStringAsFixed(1)}%'),
                ],
              )
            : Text(emptyText),
      ),
    );
  }
}

class _MistakeCategoryCard extends StatelessWidget {
  final LearningSummaryModel summary;

  const _MistakeCategoryCard({
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      _CategoryRowData(
        label: 'Grammar',
        value: summary.grammarMistakesCount,
      ),
      _CategoryRowData(
        label: 'Vocabulary',
        value: summary.vocabularyMistakesCount,
      ),
      _CategoryRowData(
        label: 'Phrasing',
        value: summary.phrasingMistakesCount,
      ),
      _CategoryRowData(
        label: 'Sentence structure',
        value: summary.sentenceStructureMistakesCount,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CategoryRow(data: category),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final _CategoryRowData data;

  const _CategoryRow({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(data.label)),
        Text(
          data.value.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
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
              'Could not load summary.',
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

class _StatCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  _StatCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });
}

class _CategoryRowData {
  final String label;
  final int value;

  _CategoryRowData({
    required this.label,
    required this.value,
  });
}

String _formatDate(DateTime? date) {
  if (date == null) {
    return '-';
  }

  return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
}