import 'package:dio/dio.dart';
import 'package:echo_app/core/network/dio_client.dart';
import 'package:echo_app/features/mistakes/data/mistake_model.dart';

class MistakeApi {
  final Dio dio = DioClient().dio;

  Future<List<MistakeModel>> getMyMistakes({
    required String token,
  }) async {
    final response = await dio.get(
      '/mistakes/my',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final data = response.data as List;

    return data
        .map((item) => MistakeModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<MistakeModel> getMyMistakeById({
    required String token,
    required String mistakeId,
  }) async {
    final response = await dio.get(
      '/mistakes/my/$mistakeId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return MistakeModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteMyMistake({
    required String token,
    required String mistakeId,
  }) async {
    await dio.delete(
      '/mistakes/my/$mistakeId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}