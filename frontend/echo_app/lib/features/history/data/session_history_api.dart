import 'package:dio/dio.dart';
import 'package:echo_app/core/network/dio_client.dart';
import 'package:echo_app/features/history/data/session_history_model.dart';

class SessionHistoryApi {
  final Dio dio = DioClient().dio;

  Future<List<SessionHistoryModel>> getMySessions({
    required String token,
  }) async {
    final response = await dio.get(
      '/sessions/my',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final data = response.data as List;

    return data
        .map((item) => SessionHistoryModel.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }
}