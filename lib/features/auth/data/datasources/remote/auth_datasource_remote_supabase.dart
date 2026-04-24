import 'package:dio/dio.dart';

import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/auth_model.dart';
import '../../models/user_model.dart';
import 'auth_datasource_remote.dart';

class AuthDataSourceRemoteSupabase implements AuthDataSourceRemote {
  final Dio dio;

  AuthDataSourceRemoteSupabase({
    required this.dio,
  });

  @override
  Future<AuthModel> login({
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

      return AuthModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } catch (_) {
      throw ServerException('Error inesperado al iniciar sesion');
    }
  }

  @override
  Future<AuthModel> verifySession() async {
    try {
      final response = await dio.get('/auth/v1/user');

      return AuthModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 &&
          e.response?.data['msg'].contains('token is expired')) {
        throw ServerException('La sesion expiro');
      }

      throw ServerException(ErrorHandler.getErrorMessage(e));
    } catch (_) {
      throw ServerException('Error inesperado al verificar la sesion');
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

      return AuthModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } catch (_) {
      throw ServerException('Error inesperado al refrescar sesion');
    }
  }

  @override
  Future<UserModel> getUser({
    required AuthModel auth,
  }) {
    return _getUserByAuthId(auth);
  }

  Future<UserModel> _getUserByAuthId(
    AuthModel auth,
  ) async {
    try {
      final userResponse = await dio.get(
        '/rest/v1/users',
        queryParameters: {
          'auth_id': 'eq.${auth.authId}',
          'select': '*',
        },
      );

      final userData = userResponse.data as List<dynamic>;
      if (userData.isEmpty) {
        throw ServerException('No se encontro el usuario');
      }

      final userJson = userData.first as Map<String, dynamic>;
      final userId = userJson['id'] as int;

      final riderResponse = await dio.get(
        '/rest/v1/riders',
        queryParameters: {
          'user_id': 'eq.$userId',
        },
      );

      final riderData = riderResponse.data as List<dynamic>;
      final riderId = riderData.isNotEmpty ? riderData.first['id'] as int : null;

      final driverResponse = await dio.get(
        '/rest/v1/drivers',
        queryParameters: {
          'user_id': 'eq.$userId',
        },
      );

      final driverData = driverResponse.data as List<dynamic>;
      final driverId = driverData.isNotEmpty ? driverData.first['id'] as int : null;

      return UserModel.fromJson(
        userJson,
        email: auth.email,
        riderId: riderId,
        driverId: driverId,
      );
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Error inesperado al obtener el usuario');
    }
  }
}
