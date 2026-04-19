import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient()
  : dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080',
    connectTimeout: const Duration(seconds: 5),
  )){
    dio.interceptors.add(LogInterceptor(
      requestBody : true,
      responseBody: true,
    ));
  }
}