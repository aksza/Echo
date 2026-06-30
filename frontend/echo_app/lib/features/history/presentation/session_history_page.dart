import 'package:echo_app/features/history/data/session_history_model.dart';
import 'package:echo_app/features/history/presentation/session_history_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionHistoryPage extends ConsumerWidget {
  const SessionHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(sessionHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning History'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(sessionHistoryProvider.notifier).loadSessions();
            },
          ),
        ],
      ),
      body: historyState.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return _HistoryErrorView(
            message: error.toString(),
            onRetry: () {
              ref.read(sessionHistoryProvider.notifier).loadSessions();
            },
          );
        },
        data: (sessions) {
          if (sessions.isEmpty) {
            return const _EmptyHistoryView();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(sessionHistoryProvider.notifier).loadSessions();
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _SessionHistoryCard(
                  session: sessions[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SessionHistoryCard extends StatelessWidget {
  final SessionHistoryModel session;

  const _SessionHistoryCard({
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final durationText = _formatDuration(
      session.startedAt,
      session.endedAt,
    );

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(_getIcon(session.sessionType)),
        ),
        title: Text(
          session.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${session.sessionType} • ${_formatDateTime(session.startedAt)}'
            '${durationText.isEmpty ? '' : ' • $durationText'}',
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String sessionType) {
    final normalized = sessionType.toLowerCase();

    if (normalized.contains('conversation')) {
      return Icons.mic;
    }

    if (normalized.contains('practice')) {
      return Icons.play_circle;
    }

    if (normalized.contains('placement')) {
      return Icons.assignment;
    }

    return Icons.history;
  }
}

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No learning sessions yet.\nStart a conversation to create your first history item.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _HistoryErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HistoryErrorView({
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
              'Could not load history.',
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

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return '-';
  }

  return '${value.year}.${value.month.toString().padLeft(2, '0')}.${value.day.toString().padLeft(2, '0')} '
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

String _formatDuration(DateTime? startedAt, DateTime? endedAt) {
  if (startedAt == null || endedAt == null) {
    return '';
  }

  final duration = endedAt.difference(startedAt);

  if (duration.inMinutes <= 0) {
    return '<1 min';
  }

  if (duration.inHours > 0) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (minutes == 0) {
      return '$hours h';
    }

    return '$hours h $minutes min';
  }

  return '${duration.inMinutes} min';
}