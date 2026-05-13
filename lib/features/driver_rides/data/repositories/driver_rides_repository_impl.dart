import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_checker.dart';
import '../../domain/entities/driver_ride.dart';
import '../../domain/entities/driver_ride_reservation.dart';
import '../../domain/repositories/driver_rides_repository.dart';
import '../data_sources/driver_rides_remote_data_source.dart';
import '../models/driver_ride_model.dart';
import '../models/driver_ride_reservation_model.dart';

class DriverRidesRepositoryImpl implements DriverRidesRepository {
  final DriverRidesRemoteDataSource remoteDataSource;
  final NetworkChecker networkChecker;

  DriverRidesRepositoryImpl({
    required this.remoteDataSource,
    required this.networkChecker,
  });

  @override
  Future<Either<Failure, DriverRide?>> getActiveDriverRide({
    required int? driverId,
  }) async {
    if (driverId == null) {
      return const Right(null);
    }

    if (!await networkChecker.hasInternet) {
      return const Left(
        NetworkFailure(
          'No tienes internet. Revisa tu conexion e intenta de nuevo.',
        ),
      );
    }

    try {
      final rideRow = await remoteDataSource.getActiveDriverRideRow(
        driverId: driverId,
      );

      if (rideRow == null) {
        return const Right(null);
      }

      final vehicleId = _toInt(rideRow['vehicle_id']);
      final vehicleRow = await remoteDataSource.getVehicleRow(
        vehicleId: vehicleId,
      );
      final passengerCapacity = (_toInt(vehicleRow['number_slots']) - 1).clamp(
        0,
        99,
      );
      final reservations = await _loadReservations(
        rideId: rideRow['id'].toString(),
      );
      final pendingReservations = reservations
          .where((reservation) => reservation.state == 'PENDIENTE')
          .toList();
      final acceptedReservations = reservations
          .where(
            (reservation) =>
                reservation.state == 'ACEPTADA' ||
                reservation.state == 'EN_CURSO',
          )
          .toList();
      final availableSlots = (passengerCapacity - acceptedReservations.length)
          .clamp(0, 99);

      final ride = DriverRideModel.fromJson(
        rideRow,
        availableSlots: availableSlots,
        pendingReservations: pendingReservations,
        acceptedReservations: acceptedReservations,
      ).toEntity();

      return Right(ride);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('Error inesperado al obtener el viaje del conductor'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateRideState({
    required String rideId,
    required String state,
  }) async {
    if (!await networkChecker.hasInternet) {
      return const Left(
        NetworkFailure(
          'No tienes internet. Esta accion requiere conexion para completarse.',
        ),
      );
    }

    try {
      await remoteDataSource.updateRideState(rideId: rideId, state: state);
      await _syncReservationsForRideState(rideId: rideId, rideState: state);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('Error inesperado al actualizar el estado del viaje'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> acceptReservation({
    required String rideId,
    required String reservationId,
  }) async {
    if (!await networkChecker.hasInternet) {
      return const Left(
        NetworkFailure(
          'No tienes internet. Esta accion requiere conexion para completarse.',
        ),
      );
    }

    try {
      await remoteDataSource.updateReservationState(
        reservationId: reservationId,
        state: 'ACEPTADA',
      );

      final rideRow = await remoteDataSource.getRideRow(rideId: rideId);
      if (rideRow == null) {
        return const Left(ServerFailure('No encontramos el viaje asociado.'));
      }

      final vehicleRow = await remoteDataSource.getVehicleRow(
        vehicleId: _toInt(rideRow['vehicle_id']),
      );
      final passengerCapacity = (_toInt(vehicleRow['number_slots']) - 1).clamp(
        0,
        99,
      );
      final reservationRows = await remoteDataSource.getReservationRows(
        rideId: rideId,
      );
      final acceptedCount = reservationRows
          .where((row) => row['state']?.toString() == 'ACEPTADA')
          .length;

      if (passengerCapacity > 0 && acceptedCount >= passengerCapacity) {
        await remoteDataSource.updateRideState(
          rideId: rideId,
          state: 'COMPLETO',
        );
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('Error inesperado al aceptar la reserva'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> rejectReservation({
    required String reservationId,
  }) async {
    if (!await networkChecker.hasInternet) {
      return const Left(
        NetworkFailure(
          'No tienes internet. Esta accion requiere conexion para completarse.',
        ),
      );
    }

    try {
      await remoteDataSource.updateReservationState(
        reservationId: reservationId,
        state: 'RECHAZADA',
      );

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('Error inesperado al rechazar la reserva'),
      );
    }
  }

  Future<List<DriverRideReservation>> _loadReservations({
    required String rideId,
  }) async {
    final reservationRows = await remoteDataSource.getReservationRows(
      rideId: rideId,
    );

    if (reservationRows.isEmpty) {
      return const [];
    }

    final riderIds = reservationRows
        .map((row) => _toInt(row['rider_id']))
        .where((id) => id > 0)
        .toSet()
        .toList();
    final riderRows = await remoteDataSource.getRiderRows(riderIds: riderIds);
    final ridersById = {
      for (final riderRow in riderRows) _toInt(riderRow['id']): riderRow,
    };
    final userIds = riderRows
        .map((row) => _toInt(row['user_id']))
        .where((id) => id > 0)
        .toSet()
        .toList();
    final userRows = await remoteDataSource.getUserRows(userIds: userIds);
    final usersById = {
      for (final userRow in userRows) _toInt(userRow['id']): userRow,
    };

    return reservationRows.map((reservationRow) {
      final riderId = _toInt(reservationRow['rider_id']);
      final riderRow = ridersById[riderId] ?? const <String, dynamic>{};
      final userId = _toInt(riderRow['user_id']);

      return DriverRideReservationModel.fromRows(
        reservationRow: reservationRow,
        riderRow: riderRow,
        userRow: usersById[userId],
      ).toEntity();
    }).toList();
  }

  Future<void> _syncReservationsForRideState({
    required String rideId,
    required String rideState,
  }) async {
    switch (rideState) {
      case 'EN_CURSO':
        await remoteDataSource.updateReservationStatesByRide(
          rideId: rideId,
          currentStates: const ['ACEPTADA'],
          nextState: 'EN_CURSO',
        );
        break;
      case 'FINALIZADO':
        await remoteDataSource.updateReservationStatesByRide(
          rideId: rideId,
          currentStates: const ['ACEPTADA', 'EN_CURSO'],
          nextState: 'FINALIZADA',
        );
        break;
      case 'CANCELADO':
        await remoteDataSource.updateReservationStatesByRide(
          rideId: rideId,
          currentStates: const ['PENDIENTE', 'ACEPTADA', 'EN_CURSO'],
          nextState: 'CANCELADA',
        );
        break;
    }
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }
}
