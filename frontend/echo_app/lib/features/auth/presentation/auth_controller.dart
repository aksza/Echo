import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';
import '../../../core/network/dio_client.dart';

final dioProvider = Provider((ref) => DioClient().dio);

final authApiProvider = Provider((ref) {
  return AuthApi(ref.read(dioProvider));
});

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(ref.read(authApiProvider));
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<String?>>((ref) {
  return AuthController(ref.read(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<String?>> {
  final AuthRepository repo;

  AuthController(this.repo) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final token = await repo.login(email, password);
      state = AsyncValue.data(token);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> register(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final token = await repo.register(email, password);
      state = AsyncValue.data(token);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}