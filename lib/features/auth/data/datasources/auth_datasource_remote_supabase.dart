import 'package:dio/dio.dart';
import '../models/auth_model.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/user_model.dart';
import 'auth_datasource_remote.dart';

class AuthDataSourceRemoteSupabase implements AuthDataSourceRemote {
  final Dio dio;
  final TokenStorage tokenStorage;

  AuthDataSourceRemoteSupabase({
    required this.dio,
    required this.tokenStorage,
  });

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/v1/token',
        queryParameters: {
          'grant_type': 'password',
        },
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      await tokenStorage.saveSession(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return await getUserByAuthId(authResponse);
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } catch (_) {
      throw ServerException('Error inesperado al iniciar sesión');
    }
  }

  @override
  Future<UserModel> restoreSession(
  ) async {
    try {
      AuthModel authResponse;
      try {
        final response = await dio.get('/auth/v1/user');

        authResponse = AuthModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 403 && e.response?.data['msg'].contains('token is expired')) {
          final refreshToken = await tokenStorage.getRefreshToken();
          if (refreshToken == null) {
            throw ServerException('No hay token de refresco disponible');
          }
          authResponse = await refreshSession(refreshToken: refreshToken);
        } else {
          throw ServerException(ErrorHandler.getErrorMessage(e));
        }
      }
      
      return await getUserByAuthId(authResponse);
    } catch (e) {
      throw ServerException('Error inesperado al restaurar sesión');
    }
  }

  @override
  Future<AuthModel> refreshSession({
    required String refreshToken,
  }) async {
    try {
      final response = await dio.post(
        '/auth/v1/token',
        queryParameters: {
          'grant_type': 'refresh_token',
        },
        data: {
          'refresh_token': refreshToken,
        },
      );

      final authResponse = AuthModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      await tokenStorage.saveSession(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse;
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } catch (_) {
      throw ServerException('Error inesperado al refrescar sesión');
    }
  }

  Future<UserModel> getUserByAuthId(AuthModel authResponse) async {
    try {
      final userResponse = await dio.get(
        '/rest/v1/users',
        queryParameters: {
          'auth_id': 'eq.${authResponse.authId}',
          'select': '*',
        },
      );

      final userData = userResponse.data as List<dynamic>;
      if (userData.isEmpty) {
        throw ServerException('No se encontró el usuario');
      }

      final userJson = userData.first as Map<String, dynamic>;
      final userId = userJson['id'] as int;

      final riderResponse = await dio.get(
        '/rest/v1/riders',
        queryParameters: {
          'user_id': 'eq.$userId'
        },
      );

      final riderData = riderResponse.data as List<dynamic>;
      final riderId = riderData.isNotEmpty ? riderData.first['id'] as int : null;

      final driverResponse = await dio.get(
        '/rest/v1/drivers',
        queryParameters: {
          'user_id': 'eq.$userId'
        },
      );

      final driverData = driverResponse.data as List<dynamic>;
      final driverId = driverData.isNotEmpty ? driverData.first['id'] as int : null;

      return UserModel.fromJson(
        userJson,
        email: authResponse.email,
        riderId: riderId,
        driverId: driverId,
      );
    } catch (e) {
      throw ServerException('Error inesperado al obtener el usuario');
    }
  }
}