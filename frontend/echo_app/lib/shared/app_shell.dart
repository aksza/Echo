import 'package:echo_app/features/conversation/presentation/conversation_page.dart';
import 'package:echo_app/features/lesson/presentation/lesson_page.dart';
import 'package:echo_app/features/mistakes/presentation/mistakes_page.dart';
import 'package:echo_app/features/practice/presentation/practice_page.dart';
import 'package:echo_app/features/summary/data/learning_summary_model.dart';
import 'package:echo_app/features/summary/presentation/learning_summary_controller.dart';
import 'package:echo_app/features/summary/presentation/learning_summary_page.dart';
import 'package:echo_app/features/vocabulary/presentation/vocabulary_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echo_app/features/history/presentation/session_history_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final List<_NavigationItem> _items = [
    _NavigationItem(
      label: 'Home',
      icon: Icons.home,
      page: const HomePage(),
    ),
    _NavigationItem(
      label: 'Lesson',
      icon: Icons.school,
      page: const LessonPage(),
    ),
    _NavigationItem(
      label: 'Practice',
      icon: Icons.play_circle,
      page: const PracticePage(),
    ),
    _NavigationItem(
      label: 'Vocabulary',
      icon: Icons.menu_book,
      page: const VocabularyPage(),
    ),
    _NavigationItem(
      label: 'Profile',
      icon: Icons.person,
      page: const LearningSummaryPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _items[_selectedIndex].page,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _items
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class _NavigationItem {
  final String label;
  final IconData icon;
  final Widget page;

  _NavigationItem({
    required this.label,
    required this.icon,
    required this.page,
  });
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryState = ref.watch(learningSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Echo'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(learningSummaryProvider.notifier).loadSummary();
            },
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
          return _HomeErrorView(
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
                  _WelcomeCard(summary: summary),
                  const SizedBox(height: 20),
                  const Text(
                    'Your progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ProgressGrid(summary: summary),
                  const SizedBox(height: 24),
                  const Text(
                    'Quick actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _QuickActions(),
                  const SizedBox(height: 24),
                  const Text(
                    'Recommended conversations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._recommendedTopics.map((topic) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _RecommendedTopicCard(topic: topic),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final LearningSummaryModel summary;

  const _WelcomeCard({
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueAccent.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(
              Icons.auto_awesome,
              size: 42,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary.dailyStreak > 0
                        ? 'You have a ${summary.dailyStreak}-day learning streak.'
                        : 'Start a conversation today to begin your streak.',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressGrid extends StatelessWidget {
  final LearningSummaryModel summary;

  const _ProgressGrid({
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ProgressCard(
                title: 'Daily streak',
                value: summary.dailyStreak.toString(),
                unit: 'days',
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ProgressCard(
                title: 'Vocabulary',
                value: summary.vocabularyCount.toString(),
                unit: 'saved words',
                icon: Icons.menu_book,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ProgressCard(
                title: 'Conversations',
                value: summary.conversationSessions.toString(),
                unit: 'AI sessions',
                icon: Icons.mic,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ProgressCard(
                title: 'Practice',
                value:
                    '${summary.vocabularyPracticeSuccessRate.toStringAsFixed(0)}%',
                unit: 'vocab success',
                icon: Icons.trending_up,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActionButton(
          icon: Icons.mic,
          label: 'Start new conversation',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ConversationPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _ActionButton(
          icon: Icons.school,
          label: 'Open research lesson',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LessonPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _ActionButton(
          icon: Icons.error_outline,
          label: 'Review mistakes',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MistakesPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _ActionButton(
          icon: Icons.history,
          label: 'View learning history',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SessionHistoryPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(label),
        ),
      ),
    );
  }
}

class _RecommendedTopicCard extends StatelessWidget {
  final _RecommendedTopic topic;

  const _RecommendedTopicCard({
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(topic.icon),
        title: Text(topic.title),
        subtitle: Text(topic.description),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConversationPage(
                lessonTitle: topic.title,
                initialSystemPrompt: topic.systemPrompt,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _ProgressCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.25),
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HomeErrorView({
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
              'Could not load dashboard.',
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

class _RecommendedTopic {
  final String title;
  final String description;
  final IconData icon;
  final String systemPrompt;

  const _RecommendedTopic({
    required this.title,
    required this.description,
    required this.icon,
    required this.systemPrompt,
  });
}

const List<_RecommendedTopic> _recommendedTopics = [
  _RecommendedTopic(
    title: 'Daily routine',
    description: 'Talk about your everyday habits and schedule.',
    icon: Icons.wb_sunny,
    systemPrompt: """
You are Echo, an AI English speaking partner.

The conversation topic is ONLY daily routine.

Important rules:
- Only discuss daily routines, habits, school days, free time and schedules.
- If the learner changes topic, politely guide them back to daily routine.
- Ask one short question at a time.
- Use A2-B1 friendly English.
- Keep your answers short.
- Encourage the learner to speak.

Example redirection:
"Let's stay with daily routines. What do you usually do after school?"
""",
  ),
  _RecommendedTopic(
    title: 'Travel and holidays',
    description: 'Practice speaking about trips, places and plans.',
    icon: Icons.flight,
    systemPrompt: """
You are Echo, an AI English speaking partner.

The conversation topic is ONLY travel and holidays.

Important rules:
- Only discuss travel, holidays, places, transport, hotels, activities and plans.
- If the learner changes topic, politely guide them back to travel.
- Ask one short question at a time.
- Use A2-B1 friendly English.
- Keep your answers short.
- Encourage the learner to speak.

Example redirection:
"Let's stay with travel. Where would you like to go on holiday?"
""",
  ),
  _RecommendedTopic(
    title: 'Technology and online safety',
    description: 'Practice the research lesson topic again.',
    icon: Icons.security,
    systemPrompt: """
You are Echo, an AI English speaking partner.

The conversation topic is ONLY technology and online safety.

Important rules:
- Only discuss technology, malware, suspicious links, passwords, personal information and safe internet habits.
- If the learner changes topic, politely guide them back to online safety.
- Ask one short question at a time.
- Use A2-B1 friendly English.
- Keep your answers short.
- Encourage the learner to speak.

Example redirection:
"Let's stay with online safety. What can happen if you click a suspicious link?"
""",
  ),
];