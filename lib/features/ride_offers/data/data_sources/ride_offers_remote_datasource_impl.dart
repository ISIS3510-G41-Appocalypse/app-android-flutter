import 'package:dio/dio.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import 'ride_offers_remote_datasource.dart';

class RideOffersRemoteDataSourceImpl implements RideOffersRemoteDataSource {
  static const String _rideOffersViewPath = '/rest/v1/ride_offers_view';
  static const String _zonesPath = '/rest/v1/zones';

  final Dio dio;

  RideOffersRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Map<String, dynamic>>> getRideOffersRows() {
    return _getTableRows(
      path: _rideOffersViewPath,
      queryParameters: const {
        'select':
            'id,driver_name,driver_rating,trips_count,price,source,destination,date,departure_time,slots,car_model,zone_name,type,state,zone_id',
        'order': 'driver_rating.desc',
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getZonesRows() {
    return _getTableRows(
      path: _zonesPath,
      queryParameters: const {'select': 'id,name'},
    );
  }

  Future<List<Map<String, dynamic>>> _getTableRows({
    required String path,
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);

      final data = response.data;

      if (data is List) {
        return data.map((item) => item as Map<String, dynamic>).toList();
      }

      throw ServerException('Formato de respuesta invalido para $path');
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Error inesperado al consultar $path');
    }
  }
}
