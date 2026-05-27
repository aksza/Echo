import 'package:echo_app/features/auth/presentation/auth_controller.dart';
import 'package:echo_app/features/vocabulary/data/vocabulary_api.dart';
import 'package:echo_app/features/vocabulary/data/vocabulary_model.dart';
import 'package:echo_app/features/vocabulary/data/vocabulary_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final vocabularyApiProvider = Provider((ref) {
  return VocabularyApi();
});

final vocabularyRepositoryProvider = Provider((ref) {
  return VocabularyRepository(
    ref.read(vocabularyApiProvider),
  );
});

final vocabularyProvider = StateNotifierProvider<VocabularyController,
    AsyncValue<List<VocabularyModel>>>((ref) {
  return VocabularyController(ref);
});

class VocabularyController
    extends StateNotifier<AsyncValue<List<VocabularyModel>>> {
  final Ref ref;

  VocabularyController(this.ref) : super(const AsyncValue.loading()) {
    loadVocabulary();
  }

  Future<void> loadVocabulary() async {
    final token = ref.read(authTokenProvider);

    if (token == null || token.isEmpty) {
      state = AsyncValue.error(
        'Missing authentication token.',
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(vocabularyRepositoryProvider);

      final words = await repository.getVocabularies(
        token: token,
      );

      state = AsyncValue.data(words);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> addVocabulary({
    required String expression,
    required String translation,
    String? exampleSentence,
  }) async {
    final token = ref.read(authTokenProvider);

    if (token == null || token.isEmpty) {
      state = AsyncValue.error(
        'Missing authentication token.',
        StackTrace.current,
      );
      return false;
    }

    if (expression.trim().isEmpty || translation.trim().isEmpty) {
      state = AsyncValue.error(
        'Expression and translation are required.',
        StackTrace.current,
      );
      return false;
    }

    try {
      final repository = ref.read(vocabularyRepositoryProvider);

      final added = await repository.addVocabulary(
        token: token,
        expression: expression.trim(),
        translation: translation.trim(),
        exampleSentence: exampleSentence?.trim().isEmpty == true
            ? null
            : exampleSentence?.trim(),

        // 0 = manual, a backend enum/int szerint
        addedFrom: 0,

        // 0 = kezdő / alap knowledge level
        knowledgeLevel: 0,
      );

      final current = state.value ?? [];

      state = AsyncValue.data([
        added,
        ...current,
      ]);

      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<void> deleteVocabulary(String vocabularyId) async {
    final token = ref.read(authTokenProvider);

    if (token == null || token.isEmpty) {
      state = AsyncValue.error(
        'Missing authentication token.',
        StackTrace.current,
      );
      return;
    }

    try {
      final repository = ref.read(vocabularyRepositoryProvider);

      await repository.deleteVocabulary(
        token: token,
        vocabularyId: vocabularyId,
      );

      final current = state.value ?? [];

      final updated = current
          .where((item) => item.id != vocabularyId)
          .toList();

      state = AsyncValue.data(updated);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}