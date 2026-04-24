import 'package:dio/dio.dart';

import '../storage/session_storage.dart';

class SessionInterceptor extends Interceptor {
  static const String _retryAfterRefreshKey = 'retry_after_session_refresh';

  final SessionStorage sessionStorage;
  final Dio refreshClient;
  Future<String?>? _pendingRefresh;

  SessionInterceptor({
    required this.sessionStorage,
    required this.refreshClient,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final session = await sessionStorage.getSession();
    final accessToken = session?.accessToken;

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetryWithRefresh(err)) {
      handler.next(err);
      return;
    }

    final refreshedAccessToken = await _refreshSessionAccessToken();
    if (refreshedAccessToken == null) {
      await sessionStorage.clearSession();
      handler.next(err);
      return;
    }

    try {
      final requestOptions = err.requestOptions;
      requestOptions.headers['Authorization'] = 'Bearer $refreshedAccessToken';
      requestOptions.extra[_retryAfterRefreshKey] = true;

      final response = await refreshClient.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (_) {
      handler.next(err);
    }
  }

  bool _shouldRetryWithRefresh(DioException error) {
    final requestOptions = error.requestOptions;

    if (requestOptions.extra[_retryAfterRefreshKey] == true) {
      return false;
    }

    if (requestOptions.path == '/auth/v1/token') {
      return false;
    }

    if (error.response?.statusCode != 403) {
      return false;
    }

    final data = error.response?.data;
    if (data is! Map<String, dynamic>) {
      return false;
    }

    final message = data['msg'] as String?;
    return message != null && message.contains('token is expired');
  }

  Future<String?> _refreshSessionAccessToken() async {
    if (_pendingRefresh != null) {
      return _pendingRefresh;
    }

    _pendingRefresh = _executeRefresh();

    try {
      return await _pendingRefresh;
    } finally {
      _pendingRefresh = null;
    }
  }

  Future<String?> _executeRefresh() async {
    final session = await sessionStorage.getSession();
    final refreshToken = session?.refreshToken;

    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await refreshClient.post(
        '/auth/v1/token',
        queryParameters: {
          'grant_type': 'refresh_token',
        },
        data: {
          'refresh_token': refreshToken,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final accessToken = data['access_token'] as String? ?? '';
      final nextRefreshToken = data['refresh_token'] as String? ?? '';

      if (accessToken.isEmpty || nextRefreshToken.isEmpty) {
        return null;
      }

      await sessionStorage.saveSession(
        accessToken: accessToken,
        refreshToken: nextRefreshToken,
      );

      return accessToken;
    } catch (_) {
      return null;
    }
  }
}
