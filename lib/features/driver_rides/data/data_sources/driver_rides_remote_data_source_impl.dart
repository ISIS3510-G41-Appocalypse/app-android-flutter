import 'package:dio/dio.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import 'driver_rides_remote_data_source.dart';

class DriverRidesRemoteDataSourceImpl implements DriverRidesRemoteDataSource {
  static const String _ridesPath = '/rest/v1/rides';
  static const String _vehiclesPath = '/rest/v1/vehicles';

  final Dio dio;

  DriverRidesRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>?> getActiveDriverRideRow({
    required int driverId,
  }) async {
    try {
      final response = await dio.get(
        _ridesPath,
        queryParameters: {
          'select': 'id,source,destination,state,departure_time,vehicle_id,date',
          'driver_id': 'eq.$driverId',
          'state': 'not.in.(FINALIZADO,CANCELADO)',
          'order': 'date.desc,departure_time.desc',
          'limit': 1,
        },
      );

      final data = response.data;

      if (data is List) {
        if (data.isEmpty) {
          return null;
        }

        return data.first as Map<String, dynamic>;
      }

      throw ServerException('Formato de respuesta invalido para rides');
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Error inesperado al consultar rides');
    }
  }

  @override
  Future<Map<String, dynamic>> getVehicleRow({required int vehicleId}) async {
    try {
      final response = await dio.get(
        _vehiclesPath,
        queryParameters: {
          'select': 'id,number_slots',
          'id': 'eq.$vehicleId',
          'limit': 1,
        },
      );

      final data = response.data;

      if (data is List && data.isNotEmpty) {
        return data.first as Map<String, dynamic>;
      }

      throw ServerException('No encontramos el vehiculo asociado al viaje');
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Error inesperado al consultar vehicles');
    }
  }
}
