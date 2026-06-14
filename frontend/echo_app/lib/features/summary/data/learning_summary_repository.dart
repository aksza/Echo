import 'package:echo_app/features/summary/data/learning_summary_api.dart';
import 'package:echo_app/features/summary/data/learning_summary_model.dart';

class LearningSummaryRepository {
  final LearningSummaryApi api;

  LearningSummaryRepository(this.api);

  Future<LearningSummaryModel> getMySummary({
    required String token,
  }) {
    return api.getMySummary(token: token);
  }
}