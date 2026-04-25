import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/driver_ride.dart';

abstract class DriverRidesRepository {
  Future<Either<Failure, DriverRide?>> getActiveDriverRide({
    required int? driverId,
  });

  Future<Either<Failure, void>> updateRideState({
    required String rideId,
    required String state,
  });

  Future<Either<Failure, void>> acceptReservation({
    required String rideId,
    required String reservationId,
  });

  Future<Either<Failure, void>> rejectReservation({
    required String reservationId,
  });
}
