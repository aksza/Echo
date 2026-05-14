import 'dart:io';
import 'package:echo_app/features/auth/presentation/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/assessment_api.dart';
import '../data/assessment_result.dart';

final assessmentApiProvider = Provider((ref) {
  return AssessmentApi(ref.read(dioProvider));
});

final writingAssessmentProvider =
    StateNotifierProvider<WritingAssessmentController, AsyncValue<AssessmentResult?>>((ref) {
  return WritingAssessmentController(ref);
});

final speakingAssessmentProvider =
    StateNotifierProvider<SpeakingAssessmentController, AsyncValue<AssessmentResult?>>((ref) {
  return SpeakingAssessmentController(ref);
});

class WritingAssessmentController
    extends StateNotifier<AsyncValue<AssessmentResult?>> {
  final Ref ref;

  WritingAssessmentController(this.ref) : super(const AsyncValue.data(null));

  void reset() {
    print('[WritingAssessmentController] Resetting to null');
    state = const AsyncValue.data(null);
  }

  Future<void> assessWriting(String text) async {
    final token = ref.read(authTokenProvider);

    if (token == null) {
      state = AsyncValue.error("Missing auth token.", StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final api = ref.read(assessmentApiProvider);
      final result = await api.assessWriting(token: token, text: text);
      state = AsyncValue.data(result);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

class SpeakingAssessmentController
    extends StateNotifier<AsyncValue<AssessmentResult?>> {
  final Ref ref;

  SpeakingAssessmentController(this.ref) : super(const AsyncValue.data(null));

  void reset() {
    print('[SpeakingAssessmentController] Resetting to null');
    state = const AsyncValue.data(null);
  }

  Future<void> assessSpeaking(File audioFile) async {
    final token = ref.read(authTokenProvider);

    if (token == null) {
      state = AsyncValue.error("Missing auth token.", StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final api = ref.read(assessmentApiProvider);
      final result = await api.assessSpeaking(
        token: token,
        audioFile: audioFile,
      );
      state = AsyncValue.data(result);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}