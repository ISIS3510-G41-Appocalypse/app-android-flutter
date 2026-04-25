import 'package:dio/dio.dart';

import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/auth_model.dart';
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
      if (e.response?.statusCode == 400 &&
          e.response?.data['msg'].contains('Invalid login credentials')) {
        throw ServerException('Credenciales invalidas');
      }

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
}
