import 'package:flutter/material.dart';

class SelectableAiText extends StatefulWidget {
  final String text;
  final void Function(String selectedText) onOpenActions;

  const SelectableAiText({
    super.key,
    required this.text,
    required this.onOpenActions,
  });

  @override
  State<SelectableAiText> createState() => _SelectableAiTextState();
}

class _SelectableAiTextState extends State<SelectableAiText> {
  final Set<int> selectedIndexes = {};

  List<String> get words {
    return widget.text
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .toList();
  }

  String get selectedText {
    final selected = selectedIndexes.toList()..sort();

    return selected
        .map((index) => words[index])
        .join(' ')
        .trim();
  }

  void toggleWord(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        selectedIndexes.add(index);
      }
    });
  }

  void clearSelection() {
    setState(() {
      selectedIndexes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wordList = words;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(wordList.length, (index) {
            final word = wordList[index];
            final isSelected = selectedIndexes.contains(index);

            return GestureDetector(
              onTap: () => toggleWord(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blueAccent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Colors.blueAccent
                        : Colors.white24,
                  ),
                ),
                child: Text(
                  word,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
        if (selectedIndexes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected: $selectedText',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          widget.onOpenActions(selectedText);
                        },
                        icon: const Icon(Icons.touch_app, size: 18),
                        label: const Text('Actions'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: clearSelection,
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}