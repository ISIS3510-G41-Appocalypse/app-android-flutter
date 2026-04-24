import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'session_interceptor.dart';

class DioClient {
  final TokenStorage tokenStorage;
  late final Dio dio;

  DioClient({required this.tokenStorage}) {
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
        tokenStorage: tokenStorage,
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
