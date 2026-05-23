import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import 'driver_rides_remote_data_source.dart';

class DriverRidesRemoteDataSourceImpl implements DriverRidesRemoteDataSource {
  final Dio dio;

  DriverRidesRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>?> getActiveDriverRideRow({
    required int driverId,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.rides,
        queryParameters: {
          'select':
              'id,source,destination,state,departure_time,vehicle_id,date,price',
          'driver_id': 'eq.$driverId',
          'state': 'in.(OFERTADO,EN_CURSO)',
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
  Future<Map<String, dynamic>?> getRideRow({required String rideId}) async {
    try {
      final response = await dio.get(
        ApiConstants.rides,
        queryParameters: {
          'select':
              'id,source,destination,state,departure_time,vehicle_id,date,price',
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
  Future<Map<String, dynamic>> getVehicleRow({required int vehicleId}) async {
    try {
      final response = await dio.get(
        ApiConstants.vehicles,
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

  @override
  Future<List<Map<String, dynamic>>> getReservationRows({
    required String rideId,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.reservations,
        queryParameters: {
          'select': 'id,ride_id,rider_id,state',
          'ride_id': 'eq.$rideId',
          'state': 'in.(PENDIENTE,ACEPTADA,EN_CURSO)',
          'order': 'id.asc',
        },
      );

      final data = response.data;

      if (data is List) {
        return data.map((item) => item as Map<String, dynamic>).toList();
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
  Future<List<Map<String, dynamic>>> getRiderRows({
    required List<int> riderIds,
  }) async {
    if (riderIds.isEmpty) {
      return const [];
    }

    try {
      final response = await dio.get(
        ApiConstants.riders,
        queryParameters: {
          'select': 'id,user_id,rating,cancellation_odds',
          'id': 'in.(${riderIds.join(',')})',
        },
      );

      final data = response.data;

      if (data is List) {
        return data.map((item) => item as Map<String, dynamic>).toList();
      }

      throw ServerException('Formato de respuesta invalido para riders');
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Error inesperado al consultar riders');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserRows({
    required List<int> userIds,
  }) async {
    if (userIds.isEmpty) {
      return const [];
    }

    try {
      final response = await dio.get(
        ApiConstants.users,
        queryParameters: {
          'select': 'id,first_name,last_name',
          'id': 'in.(${userIds.join(',')})',
        },
      );

      final data = response.data;

      if (data is List) {
        return data.map((item) => item as Map<String, dynamic>).toList();
      }

      throw ServerException('Formato de respuesta invalido para users');
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Error inesperado al consultar users');
    }
  }

  @override
  Future<Map<String, dynamic>> updateRideState({
    required String rideId,
    required String state,
  }) async {
    try {
      final response = await dio.patch(
        ApiConstants.rides,
        data: {'state': state},
        options: Options(headers: {'Prefer': 'return=representation'}),
        queryParameters: {'select': 'id,state', 'id': 'eq.$rideId'},
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
        'No fue posible persistir el cambio de estado del viaje en la BD.',
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Error inesperado al actualizar el viaje');
    }
  }

  @override
  Future<Map<String, dynamic>> updateReservationState({
    required String reservationId,
    required String state,
  }) async {
    try {
      final response = await dio.patch(
        ApiConstants.reservations,
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
  Future<void> updateReservationStatesByRide({
    required String rideId,
    required List<String> currentStates,
    required String nextState,
  }) async {
    if (currentStates.isEmpty) {
      return;
    }

    try {
      await dio.patch(
        ApiConstants.reservations,
        data: {'state': nextState},
        options: Options(headers: {'Prefer': 'return=minimal'}),
        queryParameters: {
          'ride_id': 'eq.$rideId',
          'state': 'in.(${currentStates.join(',')})',
        },
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } catch (_) {
      throw ServerException(
        'Error inesperado al actualizar las reservas del viaje',
      );
    }
  }
}
