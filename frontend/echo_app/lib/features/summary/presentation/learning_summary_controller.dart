import 'package:echo_app/features/auth/presentation/auth_controller.dart';
import 'package:echo_app/features/summary/data/learning_summary_api.dart';
import 'package:echo_app/features/summary/data/learning_summary_model.dart';
import 'package:echo_app/features/summary/data/learning_summary_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final learningSummaryApiProvider = Provider((ref) {
  return LearningSummaryApi();
});

final learningSummaryRepositoryProvider = Provider((ref) {
  return LearningSummaryRepository(
    ref.read(learningSummaryApiProvider),
  );
});

final learningSummaryProvider =
    StateNotifierProvider<LearningSummaryController,
        AsyncValue<LearningSummaryModel>>((ref) {
  return LearningSummaryController(ref);
});

class LearningSummaryController
    extends StateNotifier<AsyncValue<LearningSummaryModel>> {
  final Ref ref;

  LearningSummaryController(this.ref) : super(const AsyncValue.loading()) {
    loadSummary();
  }

  Future<void> loadSummary() async {
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
      final repository = ref.read(learningSummaryRepositoryProvider);

      final summary = await repository.getMySummary(
        token: token,
      );

      state = AsyncValue.data(summary);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}