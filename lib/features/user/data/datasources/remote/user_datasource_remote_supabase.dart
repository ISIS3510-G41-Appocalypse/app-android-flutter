import 'package:dio/dio.dart';

import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../auth/domain/entities/auth.dart';
import '../../models/profile_model.dart';
import '../../models/user_model.dart';
import 'user_datasource_remote.dart';

class UserDataSourceRemoteSupabase implements UserDataSourceRemote {
  final Dio dio;

  UserDataSourceRemoteSupabase({
    required this.dio,
  });

  @override
  Future<UserModel> loadUser({
    required Auth auth,
  }) async {
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

      final rider = await _loadProfile(
        endpoint: '/rest/v1/riders',
        userId: userId,
      );
      final driver = await _loadProfile(
        endpoint: '/rest/v1/drivers',
        userId: userId,
      );

      return UserModel.fromJson(
        userJson,
        email: auth.email,
        rider: rider,
        driver: driver,
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Error inesperado al cargar el usuario');
    }
  }

  Future<ProfileModel?> _loadProfile({
    required String endpoint,
    required int userId,
  }) async {
    final response = await dio.get(
      endpoint,
      queryParameters: {
        'user_id': 'eq.$userId',
      },
    );

    final data = response.data as List<dynamic>;
    if (data.isEmpty) {
      return null;
    }

    return ProfileModel.fromJson(
      data.first as Map<String, dynamic>,
    );
  }
}
