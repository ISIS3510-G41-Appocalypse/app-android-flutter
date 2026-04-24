import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../storage/session_storage.dart';
import 'session_interceptor.dart';

class DioClient {
  final SessionStorage sessionStorage;
  late final Dio dio;

  DioClient({required this.sessionStorage}) {
    final baseOptions = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'apikey': ApiConstants.apiKey,
      },
    );

    dio = Dio(baseOptions);
    final refreshClient = Dio(baseOptions);

    dio.interceptors.add(
      SessionInterceptor(
        sessionStorage: sessionStorage,
        refreshClient: refreshClient,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );
    }
  }
}
