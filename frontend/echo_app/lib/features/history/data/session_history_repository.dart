import 'package:echo_app/features/history/data/session_history_api.dart';
import 'package:echo_app/features/history/data/session_history_model.dart';

class SessionHistoryRepository {
  final SessionHistoryApi api;

  SessionHistoryRepository(this.api);

  Future<List<SessionHistoryModel>> getMySessions({
    required String token,
  }) {
    return api.getMySessions(token: token);
  }
}