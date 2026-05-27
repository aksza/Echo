import 'package:echo_app/features/vocabulary/presentation/vocabulary_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddVocabularySheet extends ConsumerStatefulWidget {
  const AddVocabularySheet({super.key});

  @override
  ConsumerState<AddVocabularySheet> createState() =>
      _AddVocabularySheetState();
}

class _AddVocabularySheetState extends ConsumerState<AddVocabularySheet> {
  final expressionController = TextEditingController();
  final translationController = TextEditingController();
  final exampleController = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    expressionController.dispose();
    translationController.dispose();
    exampleController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    setState(() {
      isSaving = true;
    });

    final success = await ref.read(vocabularyProvider.notifier).addVocabulary(
          expression: expressionController.text,
          translation: translationController.text,
          exampleSentence: exampleController.text,
        );

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vocabulary added.'),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add vocabulary',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: expressionController,
                decoration: const InputDecoration(
                  labelText: 'Expression / word',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: translationController,
                decoration: const InputDecoration(
                  labelText: 'Translation',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: exampleController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Example sentence optional',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isSaving ? null : save,
                  icon: const Icon(Icons.add),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(isSaving ? 'Saving...' : 'Add'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}