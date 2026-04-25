import 'package:dio/dio.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import 'rider_rides_remote_data_source.dart';

class RiderRidesRemoteDataSourceImpl implements RiderRidesRemoteDataSource {
  static const String _reservationsPath = '/rest/v1/reservations';
  static const String _rideOffersViewPath = '/rest/v1/ride_offers_view';

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
          'state': 'in.(PENDIENTE,CONFIRMADO)',
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
