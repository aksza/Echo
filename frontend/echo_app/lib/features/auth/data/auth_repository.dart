import '../data/auth_api.dart';

class AuthRepository {
  final AuthApi api;

  AuthRepository(this.api);

  Future<String> login(String email, String password) {
    return api.login(email, password);
  }

  Future<String> register({
    required String email,
    required String password,
    required int level,
    required String nativeLanguage,
    required String targetLanguage,
    required String learningGoals,
    required bool allowLearningDataSharing,
  }) {
    return api.register(
      email: email,
      password: password,
      level: level,
      nativeLanguage: nativeLanguage,
      targetLanguage: targetLanguage,
      learningGoals: learningGoals,
      allowLearningDataSharing: allowLearningDataSharing,
    );
  }
}