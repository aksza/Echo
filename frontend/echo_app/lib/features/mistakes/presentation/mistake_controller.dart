import 'package:echo_app/features/auth/presentation/auth_controller.dart';
import 'package:echo_app/features/mistakes/data/mistake_api.dart';
import 'package:echo_app/features/mistakes/data/mistake_model.dart';
import 'package:echo_app/features/mistakes/data/mistake_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mistakeApiProvider = Provider((ref) {
  return MistakeApi();
});

final mistakeRepositoryProvider = Provider((ref) {
  return MistakeRepository(
    ref.read(mistakeApiProvider),
  );
});

final mistakesProvider =
    StateNotifierProvider<MistakesController, AsyncValue<List<MistakeModel>>>(
  (ref) {
    return MistakesController(ref);
  },
);

final mistakeDetailProvider = StateNotifierProvider.family<
    MistakeDetailController,
    AsyncValue<MistakeModel?>,
    String>(
  (ref, mistakeId) {
    return MistakeDetailController(ref, mistakeId);
  },
);

class MistakesController
    extends StateNotifier<AsyncValue<List<MistakeModel>>> {
  final Ref ref;

  MistakesController(this.ref) : super(const AsyncValue.loading()) {
    loadMistakes();
  }

  Future<void> loadMistakes() async {
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
      final repository = ref.read(mistakeRepositoryProvider);

      final mistakes = await repository.getMyMistakes(
        token: token,
      );

      state = AsyncValue.data(mistakes);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteMistake(String mistakeId) async {
    final token = ref.read(authTokenProvider);

    if (token == null || token.isEmpty) {
      state = AsyncValue.error(
        'Missing authentication token.',
        StackTrace.current,
      );
      return;
    }

    try {
      final repository = ref.read(mistakeRepositoryProvider);

      await repository.deleteMyMistake(
        token: token,
        mistakeId: mistakeId,
      );

      final currentMistakes = state.value ?? [];

      final updatedMistakes = currentMistakes
          .where((mistake) => mistake.id != mistakeId)
          .toList();

      state = AsyncValue.data(updatedMistakes);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

class MistakeDetailController
    extends StateNotifier<AsyncValue<MistakeModel?>> {
  final Ref ref;
  final String mistakeId;

  MistakeDetailController(
    this.ref,
    this.mistakeId,
  ) : super(const AsyncValue.loading()) {
    loadMistake();
  }

  Future<void> loadMistake() async {
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
      final repository = ref.read(mistakeRepositoryProvider);

      final mistake = await repository.getMyMistakeById(
        token: token,
        mistakeId: mistakeId,
      );

      state = AsyncValue.data(mistake);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> deleteMistake() async {
    final token = ref.read(authTokenProvider);

    if (token == null || token.isEmpty) {
      state = AsyncValue.error(
        'Missing authentication token.',
        StackTrace.current,
      );
      return false;
    }

    try {
      final repository = ref.read(mistakeRepositoryProvider);

      await repository.deleteMyMistake(
        token: token,
        mistakeId: mistakeId,
      );

      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}