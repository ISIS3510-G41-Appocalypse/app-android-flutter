import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_checker.dart';
import '../../domain/entities/rider_ride.dart';
import '../../domain/repositories/rider_rides_repository.dart';
import '../data_sources/rider_rides_remote_data_source.dart';
import '../models/rider_ride_model.dart';

class RiderRidesRepositoryImpl implements RiderRidesRepository {
  final RiderRidesRemoteDataSource remoteDataSource;
  final NetworkChecker networkChecker;

  RiderRidesRepositoryImpl({
    required this.remoteDataSource,
    required this.networkChecker,
  });

  @override
  Future<Either<Failure, RiderRide?>> getActiveRiderRide({
    required int? riderId,
  }) async {
    if (riderId == null) {
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
      final reservationRow = await remoteDataSource.getActiveReservationRow(
        riderId: riderId,
      );

      if (reservationRow == null) {
        return const Right(null);
      }

      final rideRow = await remoteDataSource.getRideOfferRow(
        rideId: reservationRow['ride_id'].toString(),
      );

      if (rideRow == null) {
        return const Left(
          ServerFailure('No encontramos el viaje asociado a tu reserva.'),
        );
      }

      final baseRideRow = await remoteDataSource.getRideRow(
        rideId: reservationRow['ride_id'].toString(),
      );
      final driverRow = baseRideRow == null
          ? null
          : await remoteDataSource.getDriverRow(
              driverId: _toInt(baseRideRow['driver_id']),
            );

      return Right(
        RiderRideModel.fromRows(
          reservationRow: reservationRow,
          rideRow: {
            ...rideRow,
            'driver_id': baseRideRow?['driver_id'],
            'driver_user_id': driverRow?['user_id'],
          },
        ).toEntity(),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('Error inesperado al obtener tu reserva'),
      );
    }
  }

  @override
  Future<Either<Failure, RiderRide?>> getRiderRideByRideId({
    required int? riderId,
    required String rideId,
  }) async {
    if (riderId == null) {
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
      final reservationRow = await remoteDataSource.getReservationRowForRide(
        riderId: riderId,
        rideId: rideId,
      );

      if (reservationRow == null) {
        return const Right(null);
      }

      final rideRow = await remoteDataSource.getRideOfferRow(
        rideId: reservationRow['ride_id'].toString(),
      );

      if (rideRow == null) {
        return const Left(
          ServerFailure('No encontramos el viaje asociado a tu reserva.'),
        );
      }

      final baseRideRow = await remoteDataSource.getRideRow(
        rideId: reservationRow['ride_id'].toString(),
      );
      final driverRow = baseRideRow == null
          ? null
          : await remoteDataSource.getDriverRow(
              driverId: _toInt(baseRideRow['driver_id']),
            );

      return Right(
        RiderRideModel.fromRows(
          reservationRow: reservationRow,
          rideRow: {
            ...rideRow,
            'driver_id': baseRideRow?['driver_id'],
            'driver_user_id': driverRow?['user_id'],
          },
        ).toEntity(),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('Error inesperado al obtener tu reserva'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> createReservation({
    required String rideId,
    required int? riderId,
    required String meetingPoint,
    required String destinationPoint,
  }) async {
    if (riderId == null) {
      return const Left(
        ServerFailure('Tu cuenta no tiene un perfil de pasajero activo.'),
      );
    }

    if (!await networkChecker.hasInternet) {
      return const Left(
        NetworkFailure(
          'No tienes internet. Esta accion requiere conexion para completarse.',
        ),
      );
    }

    try {
      final activeReservation = await remoteDataSource.getActiveReservationRow(
        riderId: riderId,
      );

      if (activeReservation != null) {
        return const Left(
          ServerFailure('Ya tienes una reserva activa como pasajero.'),
        );
      }

      await remoteDataSource.createReservationRow(
        rideId: rideId,
        riderId: riderId,
        meetingPoint: meetingPoint,
        destinationPoint: destinationPoint,
      );

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Error inesperado al crear la reserva'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelReservation({
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
        state: 'CANCELADA',
      );

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('Error inesperado al cancelar la reserva'),
      );
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
