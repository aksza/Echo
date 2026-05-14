import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';
import '../../../core/network/dio_client.dart';

final dioProvider = Provider((ref) => DioClient().dio);

final authTokenProvider = StateProvider<String?>((ref) => null);

final authApiProvider = Provider((ref) {
  return AuthApi(ref.read(dioProvider));
});

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(ref.read(authApiProvider));
});

final lastAuthActionProvider = StateProvider<String?>((ref) => null);

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<String?>>((ref) {
  return AuthController(ref.read(authRepositoryProvider), ref);
});

class AuthController extends StateNotifier<AsyncValue<String?>> {
  final AuthRepository repo;
  final Ref ref;

  AuthController(this.repo, this.ref)
      : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final token = await repo.login(email, password);

      ref.read(authTokenProvider.notifier).state = token;
      ref.read(lastAuthActionProvider.notifier).state = 'login';

      state = AsyncValue.data(token);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String nativeLanguage,
    required String targetLanguage,
    required String learningGoals,
    required bool allowLearningDataSharing,
    int level = 1,
  }) async {
    state = const AsyncValue.loading();

    try {
      await repo.register(
        email: email,
        password: password,
        level: level,
        nativeLanguage: nativeLanguage,
        targetLanguage: targetLanguage,
        learningGoals: learningGoals,
        allowLearningDataSharing: allowLearningDataSharing,
      );

      ref.read(lastAuthActionProvider.notifier).state = 'register';

      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}