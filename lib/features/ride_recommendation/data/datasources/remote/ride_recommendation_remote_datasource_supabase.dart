import 'package:dio/dio.dart';

import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/ride_recommendation_model.dart';
import 'ride_recommendation_remote_datasource.dart';

class RideRecommendationRemoteDataSourceSupabase
    implements RideRecommendationRemoteDataSource {
  static const String _path = '/rest/v1/rider_driver_recommendation';

  final Dio dio;

  RideRecommendationRemoteDataSourceSupabase({
    required this.dio,
  });

  @override
  Future<RideRecommendationModel?> getRecommendation({
    required int riderId,
    required int driverId,
  }) async {
    try {
      final response = await dio.get(
        _path,
        queryParameters: {
          'select': 'rider_id,driver_id,rating',
          'rider_id': 'eq.$riderId',
          'driver_id': 'eq.$driverId',
          'limit': 1,
        },
      );

      final data = response.data;
      if (data is List) {
        if (data.isEmpty) {
          return null;
        }

        return RideRecommendationModel.fromJson(
          data.first as Map<String, dynamic>,
        );
      }

      throw ServerException(
        'Formato de respuesta invalido para rider_driver_recommendation',
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException(
        'Error inesperado al consultar rider_driver_recommendation',
      );
    }
  }
}
