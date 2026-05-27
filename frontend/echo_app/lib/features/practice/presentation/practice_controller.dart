import 'dart:io';

import 'package:echo_app/features/auth/presentation/auth_controller.dart';
import 'package:echo_app/features/practice/data/practice_api.dart';
import 'package:echo_app/features/practice/data/practice_models.dart';
import 'package:echo_app/features/practice/data/practice_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PracticeAnswerMode {
  text,
  voice,
}

class PracticeState {
  final String? sessionId;
  final List<PracticeItemModel> items;
  final int currentIndex;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final PracticeAnswerMode answerMode;
  final PracticeAnswerResponse? lastAnswer;
  final PracticeSummaryModel? summary;

  PracticeState({
    required this.sessionId,
    required this.items,
    required this.currentIndex,
    required this.isLoading,
    required this.isSubmitting,
    required this.errorMessage,
    required this.answerMode,
    required this.lastAnswer,
    required this.summary,
  });

  factory PracticeState.initial() {
    return PracticeState(
      sessionId: null,
      items: [],
      currentIndex: 0,
      isLoading: false,
      isSubmitting: false,
      errorMessage: null,
      answerMode: PracticeAnswerMode.text,
      lastAnswer: null,
      summary: null,
    );
  }

  PracticeItemModel? get currentItem {
    if (items.isEmpty) return null;
    if (currentIndex < 0 || currentIndex >= items.length) return null;
    return items[currentIndex];
  }

  bool get hasNextItem {
    return currentIndex < items.length - 1;
  }

  int get displayIndex {
    return items.isEmpty ? 0 : currentIndex + 1;
  }

  PracticeState copyWith({
    String? sessionId,
    List<PracticeItemModel>? items,
    int? currentIndex,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    PracticeAnswerMode? answerMode,
    PracticeAnswerResponse? lastAnswer,
    bool clearLastAnswer = false,
    PracticeSummaryModel? summary,
    bool clearSummary = false,
  }) {
    return PracticeState(
      sessionId: sessionId ?? this.sessionId,
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      answerMode: answerMode ?? this.answerMode,
      lastAnswer: clearLastAnswer ? null : lastAnswer ?? this.lastAnswer,
      summary: clearSummary ? null : summary ?? this.summary,
    );
  }
}

final practiceApiProvider = Provider((ref) {
  return PracticeApi();
});

final practiceRepositoryProvider = Provider((ref) {
  return PracticeRepository(ref.read(practiceApiProvider));
});

final practiceProvider =
    StateNotifierProvider<PracticeController, PracticeState>((ref) {
  return PracticeController(ref);
});

class PracticeController extends StateNotifier<PracticeState> {
  final Ref ref;

  PracticeController(this.ref) : super(PracticeState.initial());

  Future<void> startSession({
    int count = 5,
  }) async {
    final token = ref.read(authTokenProvider);

    if (token == null || token.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Missing authentication token.',
      );
      return;
    }

    state = PracticeState.initial().copyWith(
      isLoading: true,
      clearError: true,
      clearSummary: true,
      clearLastAnswer: true,
    );

    try {
      final repository = ref.read(practiceRepositoryProvider);

      final response = await repository.startMistakePractice(
        token: token,
        count: count,
      );

      state = state.copyWith(
        sessionId: response.sessionId,
        items: response.items,
        currentIndex: 0,
        isLoading: false,
        isSubmitting: false,
        clearError: true,
        clearLastAnswer: true,
        clearSummary: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setAnswerMode(PracticeAnswerMode mode) {
    state = state.copyWith(
      answerMode: mode,
      clearError: true,
    );
  }

  void retryCurrentItem() {
    state = state.copyWith(
      clearLastAnswer: true,
      clearError: true,
    );
  }

  void goToNextItem() {
    if (!state.hasNextItem) {
      return;
    }

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      clearLastAnswer: true,
      clearError: true,
    );
  }

  Future<void> submitTextAnswer(String answer) async {
    final token = ref.read(authTokenProvider);
    final sessionId = state.sessionId;
    final currentItem = state.currentItem;

    if (token == null || token.isEmpty) {
      state = state.copyWith(errorMessage: 'Missing authentication token.');
      return;
    }

    if (sessionId == null || currentItem == null) {
      state = state.copyWith(errorMessage: 'Practice session is not ready.');
      return;
    }

    if (answer.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please write an answer.');
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
    );

    try {
      final repository = ref.read(practiceRepositoryProvider);

      final response = await repository.submitTextAnswer(
        token: token,
        sessionId: sessionId,
        practiceItemId: currentItem.practiceItemId,
        answer: answer.trim(),
      );

      state = state.copyWith(
        isSubmitting: false,
        lastAnswer: response,
        summary: response.summary,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> submitVoiceAnswer(File audioFile) async {
    final token = ref.read(authTokenProvider);
    final sessionId = state.sessionId;
    final currentItem = state.currentItem;

    if (token == null || token.isEmpty) {
      state = state.copyWith(errorMessage: 'Missing authentication token.');
      return;
    }

    if (sessionId == null || currentItem == null) {
      state = state.copyWith(errorMessage: 'Practice session is not ready.');
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
    );

    try {
      final repository = ref.read(practiceRepositoryProvider);

      final response = await repository.submitVoiceAnswer(
        token: token,
        sessionId: sessionId,
        practiceItemId: currentItem.practiceItemId,
        audioFile: audioFile,
        language: 'en',
      );

      state = state.copyWith(
        isSubmitting: false,
        lastAnswer: response,
        summary: response.summary,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> skipCurrentItem() async {
    final token = ref.read(authTokenProvider);
    final sessionId = state.sessionId;
    final currentItem = state.currentItem;

    if (token == null || token.isEmpty) {
      state = state.copyWith(errorMessage: 'Missing authentication token.');
      return;
    }

    if (sessionId == null || currentItem == null) {
      state = state.copyWith(errorMessage: 'Practice session is not ready.');
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
    );

    try {
      final repository = ref.read(practiceRepositoryProvider);

      final response = await repository.skipMistake(
        token: token,
        sessionId: sessionId,
        practiceItemId: currentItem.practiceItemId,
      );

      if (response.summary != null) {
        state = state.copyWith(
          isSubmitting: false,
          lastAnswer: response,
          summary: response.summary,
        );
        return;
      }

      if (state.hasNextItem) {
        state = state.copyWith(
          currentIndex: state.currentIndex + 1,
          isSubmitting: false,
          clearLastAnswer: true,
          clearError: true,
        );
      } else {
        await endSession();
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> endSession() async {
    final token = ref.read(authTokenProvider);
    final sessionId = state.sessionId;

    if (token == null || token.isEmpty) {
      state = state.copyWith(errorMessage: 'Missing authentication token.');
      return;
    }

    if (sessionId == null || sessionId.isEmpty) {
      state = state.copyWith(errorMessage: 'Practice session is not ready.');
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
    );

    try {
      final repository = ref.read(practiceRepositoryProvider);

      final summary = await repository.endSession(
        token: token,
        sessionId: sessionId,
      );

      state = state.copyWith(
        isSubmitting: false,
        summary: summary,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = PracticeState.initial();
  }
}