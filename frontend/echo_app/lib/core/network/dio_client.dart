import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  final Dio dio;
  
  static String get _baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:5269/api';
  }

  DioClient()
  : dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 5),
    headers: {
      'Content-Type': 'application/json',
    },
  )){
    dio.interceptors.add(LogInterceptor(
      requestBody : true,
      responseBody: true,
    ));
  }
}