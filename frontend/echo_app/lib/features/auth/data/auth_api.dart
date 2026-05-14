import 'package:dio/dio.dart';

class AuthApi {
  final Dio dio;

  AuthApi(this.dio);

  Future<String> login(String email, String password) async {
    print('=== LOGIN DEBUG ===');

    final res = await dio.post(
      '/users/login',
      data: {
        "email": email.trim(),
        "password": password.trim(),
      },
    );

    print('Login successful: ${res.data}');

    return res.data["accessToken"];
  }

  Future<void> register({
    required String email,
    required String password,
    required int level,
    required String nativeLanguage,
    required String targetLanguage,
    required String learningGoals,
    required bool allowLearningDataSharing,
  }) async {
    print('=== REGISTER DEBUG ===');

    final res = await dio.post(
      '/users/register',
      data: {
        "email": email.trim(),
        "password": password.trim(),
        "level": level,
        "nativeLanguage": nativeLanguage,
        "targetLanguage": targetLanguage,
        "learningGoals": learningGoals,
        "allowLearningDataSharing": allowLearningDataSharing,
      },
    );

    print('Register successful: ${res.data}');
  }
}