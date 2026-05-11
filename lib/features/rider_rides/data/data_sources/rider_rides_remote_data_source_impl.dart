import 'package:dio/dio.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import 'rider_rides_remote_data_source.dart';

class RiderRidesRemoteDataSourceImpl implements RiderRidesRemoteDataSource {
  static const String _reservationsPath = '/rest/v1/reservations';
  static const String _rideOffersViewPath = '/rest/v1/ride_offers_view';
  static const String _ridesPath = '/rest/v1/rides';
  static const String _driversPath = '/rest/v1/drivers';

  final Dio dio;

  RiderRidesRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>?> getActiveReservationRow({
    required int riderId,
  }) async {
    try {
      final response = await dio.get(
        _reservationsPath,
        queryParameters: {
          'select': 'id,ride_id,rider_id,meeting_point,state,destination_point',
          'rider_id': 'eq.$riderId',
          'state': 'in.(PENDIENTE,ACEPTADA,EN_CURSO)',
          'order': 'id.desc',
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

      throw ServerException('Formato de respuesta invalido para reservations');
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Error inesperado al consultar reservations');
    }
  }

  @override
  Future<Map<String, dynamic>?> getRideOfferRow({
    required String rideId,
  }) async {
    try {
      final response = await dio.get(
        _rideOffersViewPath,
        queryParameters: {
          'select':
              'id,driver_name,price,source,destination,date,departure_time,car_model',
          'id': 'eq.$rideId',
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

      throw ServerException(
        'Formato de respuesta invalido para ride_offers_view',
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Error inesperado al consultar ride_offers_view');
    }
  }

  @override
  Future<Map<String, dynamic>?> getRideRow({required String rideId}) async {
    try {
      final response = await dio.get(
        _ridesPath,
        queryParameters: {
          'select': 'id,driver_id,state',
          'id': 'eq.$rideId',
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
  Future<Map<String, dynamic>?> getDriverRow({required int driverId}) async {
    try {
      final response = await dio.get(
        _driversPath,
        queryParameters: {
          'select': 'id,user_id',
          'id': 'eq.$driverId',
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

      throw ServerException('Formato de respuesta invalido para drivers');
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Error inesperado al consultar drivers');
    }
  }

  @override
  Future<void> createReservationRow({
    required String rideId,
    required int riderId,
    required String meetingPoint,
    required String destinationPoint,
  }) async {
    try {
      await dio.post(
        _reservationsPath,
        data: {
          'ride_id': int.tryParse(rideId) ?? rideId,
          'rider_id': riderId,
          'meeting_point': meetingPoint,
          'destination_point': destinationPoint,
          'state': 'PENDIENTE',
        },
        options: Options(headers: {'Prefer': 'return=minimal'}),
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } catch (_) {
      throw ServerException('Error inesperado al crear la reserva');
    }
  }
}
