import 'package:dio/dio.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final TokenStorage tokenStorage;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.tokenStorage,
  });

  @override
  Future<AuthResponseModel> login({
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

      final authResponse = AuthResponseModel.fromJson(
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
      throw ServerException('Error inesperado al iniciar sesión');
    }
  }

  @override
  Future<AuthResponseModel> refreshSession({
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

      final refreshed = AuthResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      await tokenStorage.saveSession(
        accessToken: refreshed.accessToken,
        refreshToken: refreshed.refreshToken,
      );

      return refreshed;
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } catch (_) {
      throw ServerException('Error inesperado al refrescar sesión');
    }
  }

  @override
  Future<UserModel> getUserByAuthId({
    required AuthResponseModel authResponse,
  }) async {
    try {
      final response = await dio.get(
        '/rest/v1/users',
        queryParameters: {
          'auth_id': 'eq.${authResponse.authId}',
          'select': '*',
        },
      );

      final data = response.data as List<dynamic>;

      if (data.isEmpty) {
        throw ServerException('No se encontró el usuario');
      }

      return UserModel.fromJson(
        data.first as Map<String, dynamic>,
        email: authResponse.email,
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } catch (_) {
      throw ServerException('Error inesperado al consultar usuario');
    }
  }
}