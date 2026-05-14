import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssessmentData {
  final String writingText;
  final File? audioFile;

  AssessmentData({
    required this.writingText,
    this.audioFile,
  });

  AssessmentData copyWith({
    String? writingText,
    File? audioFile,
  }) {
    return AssessmentData(
      writingText: writingText ?? this.writingText,
      audioFile: audioFile ?? this.audioFile,
    );
  }
}

class AssessmentDataNotifier extends StateNotifier<AssessmentData> {
  AssessmentDataNotifier()
      : super(AssessmentData(writingText: '', audioFile: null));

  void setWritingText(String text) {
    state = state.copyWith(writingText: text);
    print('[AssessmentData] Writing text saved: ${text.length} chars');
  }

  void setAudioFile(File? file) {
    state = state.copyWith(audioFile: file);
    print('[AssessmentData] Audio file saved: ${file?.path}');
  }

  void clear() {
    state = AssessmentData(writingText: '', audioFile: null);
    print('[AssessmentData] Cleared');
  }
}

final assessmentDataProvider =
    StateNotifierProvider<AssessmentDataNotifier, AssessmentData>((ref) {
  return AssessmentDataNotifier();
});
