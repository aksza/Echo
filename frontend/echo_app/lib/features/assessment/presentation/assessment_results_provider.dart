import 'package:echo_app/features/assessment/data/assessment_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssessmentResultsNotifier extends StateNotifier<({AssessmentResult? writing, AssessmentResult? speaking})> {
  AssessmentResultsNotifier() : super((writing: null, speaking: null));

  void setWritingResult(AssessmentResult result) {
    state = (writing: result, speaking: state.speaking);
  }

  void setSpeakingResult(AssessmentResult result) {
    state = (writing: state.writing, speaking: result);
  }

  void clear() {
    state = (writing: null, speaking: null);
  }
}

final assessmentResultsProvider = StateNotifierProvider<
    AssessmentResultsNotifier,
    ({AssessmentResult? writing, AssessmentResult? speaking})>(
  (ref) => AssessmentResultsNotifier(),
);
