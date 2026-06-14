import 'package:dio/dio.dart';
import 'package:echo_app/core/network/dio_client.dart';
import 'package:echo_app/features/summary/data/learning_summary_model.dart';

class LearningSummaryApi {
  final Dio dio = DioClient().dio;

  Future<LearningSummaryModel> getMySummary({
    required String token,
  }) async {
    final response = await dio.get(
      '/learning-summary/me',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final data = response.data['data'];

    return LearningSummaryModel.fromJson(
      data as Map<String, dynamic>,
    );
  }
}