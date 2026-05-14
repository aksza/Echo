import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationData {
  final String email;
  final String password;
  final String nativeLanguage;
  final String targetLanguage;
  final String learningGoals;
  final bool allowLearningDataSharing;

  RegistrationData({
    required this.email,
    required this.password,
    required this.nativeLanguage,
    required this.targetLanguage,
    required this.learningGoals,
    required this.allowLearningDataSharing,
  });
}

class RegistrationDataNotifier extends StateNotifier<RegistrationData?> {
  RegistrationDataNotifier() : super(null);

  void setData({
    required String email,
    required String password,
    required String nativeLanguage,
    required String targetLanguage,
    required String learningGoals,
    required bool allowLearningDataSharing,
  }) {
    state = RegistrationData(
      email: email,
      password: password,
      nativeLanguage: nativeLanguage,
      targetLanguage: targetLanguage,
      learningGoals: learningGoals,
      allowLearningDataSharing: allowLearningDataSharing,
    );
    print('[RegistrationData] Saved: email=$email, lang=$targetLanguage');
  }

  void clear() {
    state = null;
    print('[RegistrationData] Cleared');
  }
}

final registrationDataProvider =
    StateNotifierProvider<RegistrationDataNotifier, RegistrationData?>((ref) {
  return RegistrationDataNotifier();
});
