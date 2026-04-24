import 'package:dio/dio.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_profile_model.dart';
import 'user_datasource_remote.dart';

class UserDataSourceRemoteSupabase implements UserDataSourceRemote {
  final Dio dio;

  UserDataSourceRemoteSupabase({
    required this.dio,
  });

  @override
  Future<UserProfileModel> getRiderProfile({
    required int riderId,
  }) async {
    try {
      final response = await dio.get(
        '/rest/v1/riders',
        queryParameters: {
          'id': 'eq.$riderId',
        },
      );

      final data = response.data as List<dynamic>;
      if (data.isEmpty) {
        throw ServerException('No se encontro la informacion del rider');
      }

      return UserProfileModel.fromJson(
        data.first as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Error inesperado al consultar el rider');
    }
  }

  @override
  Future<UserProfileModel> getDriverProfile({
    required int driverId,
  }) async {
    try {
      final response = await dio.get(
        '/rest/v1/drivers',
        queryParameters: {
          'id': 'eq.$driverId',
        },
      );

      final data = response.data as List<dynamic>;
      if (data.isEmpty) {
        throw ServerException('No se encontro la informacion del driver');
      }

      return UserProfileModel.fromJson(
        data.first as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Error inesperado al consultar el driver');
    }
  }
}
