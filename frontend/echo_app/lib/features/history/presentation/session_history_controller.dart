import 'package:echo_app/features/auth/presentation/auth_controller.dart';
import 'package:echo_app/features/history/data/session_history_api.dart';
import 'package:echo_app/features/history/data/session_history_model.dart';
import 'package:echo_app/features/history/data/session_history_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionHistoryApiProvider = Provider((ref) {
  return SessionHistoryApi();
});

final sessionHistoryRepositoryProvider = Provider((ref) {
  return SessionHistoryRepository(
    ref.read(sessionHistoryApiProvider),
  );
});

final sessionHistoryProvider =
    StateNotifierProvider<SessionHistoryController,
        AsyncValue<List<SessionHistoryModel>>>((ref) {
  return SessionHistoryController(ref);
});

class SessionHistoryController
    extends StateNotifier<AsyncValue<List<SessionHistoryModel>>> {
  final Ref ref;

  SessionHistoryController(this.ref) : super(const AsyncValue.loading()) {
    loadSessions();
  }

  Future<void> loadSessions() async {
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
      final repository = ref.read(sessionHistoryRepositoryProvider);

      final sessions = await repository.getMySessions(
        token: token,
      );

      state = AsyncValue.data(sessions);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}