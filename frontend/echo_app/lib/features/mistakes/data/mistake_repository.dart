import 'package:echo_app/features/mistakes/data/mistake_api.dart';
import 'package:echo_app/features/mistakes/data/mistake_model.dart';

class MistakeRepository {
  final MistakeApi api;

  MistakeRepository(this.api);

  Future<List<MistakeModel>> getMyMistakes({
    required String token,
  }) {
    return api.getMyMistakes(token: token);
  }

  Future<MistakeModel> getMyMistakeById({
    required String token,
    required String mistakeId,
  }) {
    return api.getMyMistakeById(
      token: token,
      mistakeId: mistakeId,
    );
  }

  Future<void> deleteMyMistake({
    required String token,
    required String mistakeId,
  }) {
    return api.deleteMyMistake(
      token: token,
      mistakeId: mistakeId,
    );
  }
}