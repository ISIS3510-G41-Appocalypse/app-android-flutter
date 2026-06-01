import 'dart:io';

import 'package:dio/dio.dart';

class ErrorHandler {
  const ErrorHandler._();

  static String getErrorMessage(DioException e) {
    if (isNetworkError(e)) {
      return 'No tienes internet en este momento. Cuando vuelva la conexion podras intentarlo nuevamente.';
    }

    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      return data['msg']?.toString() ??
          data['message']?.toString() ??
          data['error_description']?.toString() ??
          data['error']?.toString() ??
          e.message ??
          'Ocurrio un error inesperado.';
    }

    return e.message ?? 'Ocurrio un error inesperado.';
  }

  static bool isNetworkError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.error is SocketException) {
      return true;
    }

    final message = e.message?.toLowerCase() ?? '';
    return message.contains('connection reset by peer') ||
        message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('network is unreachable');
  }
}
