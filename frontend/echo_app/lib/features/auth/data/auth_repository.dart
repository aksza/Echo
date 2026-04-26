import '../data/auth_api.dart';

class AuthRepository {
  final AuthApi api;

  AuthRepository(this.api);

  Future<String> login(String email, String password) {
    return api.login(email, password);
  }

  Future<String> register(String email, String password) {
    return api.register(email, password);
  }
}