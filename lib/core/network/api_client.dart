import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = "https://nganjukabirupa.pbltifnganjuk.com/nganjukabirupa/apimobile/";

  static Dio getClient() {
    Dio dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // Logging Interceptor
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    return dio;
  }
}