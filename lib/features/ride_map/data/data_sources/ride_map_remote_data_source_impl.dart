import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import 'ride_map_remote_data_source.dart';

class RideMapRemoteDataSourceImpl implements RideMapRemoteDataSource {
  final Dio dio;

  RideMapRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Map<String, dynamic>>> getRideLocationRows({
    required String rideId,
    required List<int> userIds,
  }) async {
    if (userIds.isEmpty) {
      return const [];
    }

    try {
      final response = await dio.get(
        ApiConstants.userSharedLocations,
        queryParameters: {
          'select':
              'id,user_id,ride_id,latitude,longitude,timestamp,is_sharing_enabled',
          'ride_id': 'eq.$rideId',
          'user_id': 'in.(${userIds.join(',')})',
          'is_sharing_enabled': 'eq.true',
          'order': 'timestamp.desc',
        },
      );

      final data = response.data;
      if (data is List) {
        return data.map((item) => item as Map<String, dynamic>).toList();
      }

      throw ServerException(
        'Formato de respuesta invalido para user_shared_locations',
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException(
        'Error inesperado al consultar user_shared_locations',
      );
    }
  }

  @override
  Future<void> createUserLocation({
    required String rideId,
    required int userId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final hasExistingLocation = await _hasUserRideLocation(
        rideId: rideId,
        userId: userId,
      );
      final locationData = {
        'user_id': userId,
        'ride_id': int.tryParse(rideId) ?? rideId,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'is_sharing_enabled': true,
      };

      if (!hasExistingLocation) {
        await dio.post(
          ApiConstants.userSharedLocations,
          data: locationData,
          options: Options(headers: {'Prefer': 'return=minimal'}),
        );
        return;
      }

      await dio.patch(
        ApiConstants.userSharedLocations,
        queryParameters: {'ride_id': 'eq.$rideId', 'user_id': 'eq.$userId'},
        data: locationData,
        options: Options(headers: {'Prefer': 'return=minimal'}),
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } catch (_) {
      throw ServerException('Error inesperado al actualizar tu ubicacion');
    }
  }

  Future<bool> _hasUserRideLocation({
    required String rideId,
    required int userId,
  }) async {
    final response = await dio.get(
      ApiConstants.userSharedLocations,
      queryParameters: {
        'select': 'id',
        'ride_id': 'eq.$rideId',
        'user_id': 'eq.$userId',
        'order': 'timestamp.desc',
        'limit': 1,
      },
    );

    final data = response.data;
    return data is List && data.isNotEmpty;
  }
}
