import 'dart:io';

import 'package:echo_app/features/practice/data/practice_api.dart';
import 'package:echo_app/features/practice/data/practice_models.dart';

class PracticeRepository {
  final PracticeApi api;

  PracticeRepository(this.api);

  Future<StartPracticeSessionResponse> startMistakePractice({
    required String token,
    int count = 5,
  }) {
    return api.startMistakePractice(
      token: token,
      count: count,
    );
  }

  Future<PracticeAnswerResponse> submitTextAnswer({
    required String token,
    required String sessionId,
    required String practiceItemId,
    required String answer,
  }) {
    return api.submitTextAnswer(
      token: token,
      sessionId: sessionId,
      practiceItemId: practiceItemId,
      answer: answer,
    );
  }

  Future<PracticeAnswerResponse> submitVoiceAnswer({
    required String token,
    required String sessionId,
    required String practiceItemId,
    required File audioFile,
    String language = 'en',
  }) {
    return api.submitVoiceAnswer(
      token: token,
      sessionId: sessionId,
      practiceItemId: practiceItemId,
      audioFile: audioFile,
      language: language,
    );
  }

  Future<PracticeAnswerResponse> skipMistake({
    required String token,
    required String sessionId,
    required String practiceItemId,
  }) {
    return api.skipMistake(
      token: token,
      sessionId: sessionId,
      practiceItemId: practiceItemId,
    );
  }

  Future<PracticeSummaryModel> endSession({
    required String token,
    required String sessionId,
  }) {
    return api.endSession(
      token: token,
      sessionId: sessionId,
    );
  }

  Future<PracticeSummaryModel> getSummary({
    required String token,
    required String sessionId,
  }) {
    return api.getSummary(
      token: token,
      sessionId: sessionId,
    );
  }
}