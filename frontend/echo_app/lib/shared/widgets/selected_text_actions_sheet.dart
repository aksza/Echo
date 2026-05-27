import 'package:audioplayers/audioplayers.dart';
import 'package:echo_app/features/auth/presentation/auth_controller.dart';
import 'package:echo_app/features/conversation/data/selected_text_actions_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedTextActionsSheet extends ConsumerStatefulWidget {
  final String selectedText;

  const SelectedTextActionsSheet({
    super.key,
    required this.selectedText,
  });

  @override
  ConsumerState<SelectedTextActionsSheet> createState() =>
      _SelectedTextActionsSheetState();
}

class _SelectedTextActionsSheetState
    extends ConsumerState<SelectedTextActionsSheet> {
  final SelectedTextActionsApi api = SelectedTextActionsApi();
  final AudioPlayer player = AudioPlayer();

  bool isSpeaking = false;
  bool isTranslating = false;
  bool isAdding = false;

  String? translation;
  String? errorMessage;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  String? get token => ref.read(authTokenProvider);

  Future<void> speakSelectedText() async {
    if (token == null || token!.isEmpty) {
      setState(() {
        errorMessage = 'Missing authentication token.';
      });
      return;
    }

    setState(() {
      isSpeaking = true;
      errorMessage = null;
    });

    try {
      final audioUrl = await api.speakText(
        token: token!,
        text: widget.selectedText,
        language: 'en',
      );

      if (audioUrl.isNotEmpty) {
        await player.play(UrlSource(audioUrl));
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isSpeaking = false;
        });
      }
    }
  }

  Future<void> translateSelectedText() async {
    if (token == null || token!.isEmpty) {
      setState(() {
        errorMessage = 'Missing authentication token.';
      });
      return;
    }

    setState(() {
      isTranslating = true;
      errorMessage = null;
    });

    try {
      final result = await api.translateText(
        token: token!,
        text: widget.selectedText,
        sourceLanguage: 'en',
        targetLanguage: 'hu',
      );

      setState(() {
        translation = result;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isTranslating = false;
        });
      }
    }
  }

  Future<void> addToVocabulary() async {
    if (token == null || token!.isEmpty) {
      setState(() {
        errorMessage = 'Missing authentication token.';
      });
      return;
    }

    if (translation == null || translation!.trim().isEmpty) {
      await translateSelectedText();
    }

    if (translation == null || translation!.trim().isEmpty) {
      setState(() {
        errorMessage = 'Translation is missing.';
      });
      return;
    }

    setState(() {
      isAdding = true;
      errorMessage = null;
    });

    try {
      await api.addToVocabulary(
        token: token!,
        expression: widget.selectedText,
        translation: translation!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to vocabulary.'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isAdding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = isSpeaking || isTranslating || isAdding;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected text',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.selectedText,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (translation != null) ...[
              const SizedBox(height: 18),
              const Text(
                'Translation',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                translation!,
                style: const TextStyle(fontSize: 18),
              ),
            ],
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isBusy ? null : speakSelectedText,
                    icon: const Icon(Icons.volume_up),
                    label: Text(isSpeaking ? 'Speaking...' : 'Speak'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isBusy ? null : translateSelectedText,
                    icon: const Icon(Icons.translate),
                    label: Text(
                      isTranslating ? 'Translating...' : 'Translate',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isBusy ? null : addToVocabulary,
                icon: const Icon(Icons.add),
                label: Text(isAdding ? 'Adding...' : 'Add to vocabulary'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}