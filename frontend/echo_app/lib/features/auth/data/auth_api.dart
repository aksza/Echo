import 'package:dio/dio.dart';

class AuthApi {
  final Dio dio;

  AuthApi(this.dio);

  Future<String> login(String email, String password) async {
    print('=== LOGIN DEBUG ===');
    print('Email: $email');
    print('Password: $password');
    print('Email trimmed: "${email.trim()}"');
    print('Password trimmed: "${password.trim()}"');
    
    try {
      final res = await dio.post('/users/login', data: {
        "email": email.trim(),
        "password": password.trim(),
      });

      print('Login successful: ${res.data}');
      return res.data["accessToken"];
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<String> register({
    required String email,
    required String password,
    required int level,
    required String nativeLanguage,
    required String targetLanguage,
    required String learningGoals,
    required bool allowLearningDataSharing,
  }) async {
    print('=== REGISTER DEBUG ===');
    print('Email: $email');
    print('Password: $password');
    
    try {
      final res = await dio.post('/users/register', data: {
        "email": email.trim(),
        "password": password.trim(),
        "level": level,
        "nativeLanguage": nativeLanguage,
        "targetLanguage": targetLanguage,
        "learningGoals": learningGoals,
        "allowLearningDataSharing": allowLearningDataSharing,
      });

      print('Register response: ${res.data}');
      
      // Register doesn't return a token, so auto-login
      print('Auto-logging in after registration...');
      final loginRes = await login(email.trim(), password.trim());
      print('Auto-login successful, token: $loginRes');
      return loginRes;
    } catch (e) {
      print('Register error: $e');
      rethrow;
    }
  }
}