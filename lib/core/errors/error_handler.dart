import 'package:dio/dio.dart';

class ErrorHandler {
  const ErrorHandler._();

  static String getErrorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      return data['msg']?.toString() ??
          data['message']?.toString() ??
          data['error_description']?.toString() ??
          data['error']?.toString() ??
          e.message ??
          'Ocurrió un error inesperado';
    }

    return e.message ?? 'Ocurrió un error inesperado';
  }
}