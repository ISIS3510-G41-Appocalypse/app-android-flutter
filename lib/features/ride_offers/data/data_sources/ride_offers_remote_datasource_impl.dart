import 'package:dio/dio.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import 'ride_offers_remote_datasource.dart';

class RideOffersRemoteDataSourceImpl implements RideOffersRemoteDataSource {
  static const String _ridesPath = '/rest/v1/rides';
  static const String _vehiclesPath = '/rest/v1/vehicles';
  static const String _driversPath = '/rest/v1/drivers';
  static const String _usersPath = '/rest/v1/users';
  static const String _zonesPath = '/rest/v1/zones';

  final Dio dio;

  RideOffersRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Map<String, dynamic>>> getRides() {
    return _getTableRows(
      path: _ridesPath,
      queryParameters: const {
        'select':
            'id,driver_id,vehicle_id,zone_id,source,destination,date,departure_time,state,type,price',
        'state': 'eq.OFERTADO',
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getVehicles() {
    return _getTableRows(
      path: _vehiclesPath,
      queryParameters: const {'select': 'id,model,number_slots,driver_id'},
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getDrivers() {
    return _getTableRows(
      path: _driversPath,
      queryParameters: const {'select': 'id,rating,user_id'},
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getUsers() {
    return _getTableRows(
      path: _usersPath,
      queryParameters: const {'select': 'id,first_name,last_name'},
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getZones() {
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
