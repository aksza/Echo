import 'package:echo_app/features/conversation/presentation/conversation_page.dart';
import 'package:echo_app/features/mistakes/presentation/mistakes_page.dart';
import 'package:echo_app/features/practice/presentation/practice_page.dart';
import 'package:echo_app/features/vocabulary/presentation/vocabulary_page.dart';
import 'package:echo_app/features/lesson/presentation/lesson_page.dart';
import 'package:flutter/material.dart';
import 'package:echo_app/features/summary/presentation/learning_summary_page.dart';

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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final recentConversations = [
      {
        'topic': 'Daily Routine',
        'date': 'Today',
        'duration': '5 min',
      },
      {
        'topic': 'Travel Plans',
        'date': 'Yesterday',
        'duration': '8 min',
      },
      {
        'topic': 'Food & Restaurants',
        'date': '2 days ago',
        'duration': '6 min',
      },
    ];

    final dailyRecommendations = [
      {
        'type': 'Practice',
        'title': 'Review saved mistakes',
        'description': 'Practice your previous grammar mistakes',
      },
      {
        'type': 'Vocabulary',
        'title': 'Review saved words',
        'description': 'Repeat your saved expressions',
      },
      {
        'type': 'Conversation',
        'title': 'Speak with Echo',
        'description': 'Start a short AI conversation',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Echo'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Continue your language learning journey',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConversationPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.mic),
                label: const Text('Start Conversation with AI'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MistakesPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.error_outline),
                label: const Text('My Mistakes'),
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Your Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: const [
                Expanded(
                  child: _ProgressCard(
                    title: 'Daily Streak',
                    value: '0',
                    unit: 'days',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _ProgressCard(
                    title: 'Level',
                    value: 'A2',
                    unit: 'Elementary',
                    icon: Icons.trending_up,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Recent Conversations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            ...recentConversations.map((conv) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.chat_bubble),
                    title: Text(conv['topic'] as String),
                    subtitle: Text(
                      '${conv['date'] as String} • ${conv['duration'] as String}',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward,
                      size: 18,
                    ),
                    onTap: () {},
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            const Text(
              'Daily Recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            ...dailyRecommendations.map((rec) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    title: Text(rec['title'] as String),
                    subtitle: Text(rec['description'] as String),
                    trailing: Chip(
                      label: Text(rec['type'] as String),
                      visualDensity: VisualDensity.compact,
                    ),
                    onTap: () {},
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),
          ],
        ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
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
              fontSize: 24,
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