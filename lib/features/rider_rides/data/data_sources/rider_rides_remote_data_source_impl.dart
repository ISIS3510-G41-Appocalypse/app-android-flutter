import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/performance/performance_features.dart';
import '../../../../core/performance/performance_time_tracker.dart';
import 'rider_rides_remote_data_source.dart';

class RiderRidesRemoteDataSourceImpl implements RiderRidesRemoteDataSource {
  static const String _reservationsPath = '/rest/v1/reservations';
  static const String _rideOffersViewPath = '/rest/v1/ride_offers_view';
  static const String _ridesPath = '/rest/v1/rides';
  static const String _driversPath = '/rest/v1/drivers';

  final Dio dio;
  final PerformanceTimeTracker performanceTimeTracker;

  RiderRidesRemoteDataSourceImpl({
    required this.dio,
    required this.performanceTimeTracker,
  });

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
  Future<Map<String, dynamic>?> getReservationRowForRide({
    required int riderId,
    required String rideId,
  }) async {
    try {
      final response = await dio.get(
        _reservationsPath,
        queryParameters: {
          'select': 'id,ride_id,rider_id,meeting_point,state,destination_point',
          'rider_id': 'eq.$riderId',
          'ride_id': 'eq.$rideId',
          'state': 'in.(PENDIENTE,ACEPTADA,EN_CURSO,FINALIZADA)',
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
  Future<Map<String, dynamic>> updateReservationState({
    required String reservationId,
    required String state,
  }) async {
    try {
      final response = await dio.patch(
        _reservationsPath,
        data: {'state': state},
        options: Options(headers: {'Prefer': 'return=representation'}),
        queryParameters: {'select': 'id,state', 'id': 'eq.$reservationId'},
      );

      final data = response.data;

      if (data is List && data.isNotEmpty) {
        final updatedRow = data.first as Map<String, dynamic>;
        final updatedState = updatedRow['state']?.toString();

        if (updatedState == state) {
          return updatedRow;
        }
      }

      throw ServerException(
        'No fue posible persistir el cambio de estado de la reserva.',
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Error inesperado al actualizar la reserva');
    }
  }

  @override
  Future<void> createReservationRow({
    required String rideId,
    required int riderId,
    required String meetingPoint,
    required String destinationPoint,
  }) async {
    final stopwatch = Stopwatch()..start();

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
      stopwatch.stop();

      unawaited(
        performanceTimeTracker.track(
          feature: PerformanceFeatures.createReservation,
          duration: stopwatch.elapsedMilliseconds.toDouble(),
          source: PerformanceSources.backEnd,
        ),
      );
    } on DioException catch (e) {
      stopwatch.stop();

      unawaited(
        performanceTimeTracker.track(
          feature: PerformanceFeatures.createReservation,
          duration: stopwatch.elapsedMilliseconds.toDouble(),
          source: PerformanceSources.backEnd,
        ),
      );

      throw ServerException(ErrorHandler.getErrorMessage(e));
    } catch (_) {
      throw ServerException('Error inesperado al crear la reserva');
    }
  }
}
