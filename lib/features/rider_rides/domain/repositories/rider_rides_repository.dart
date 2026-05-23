import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/rider_ride.dart';

abstract class RiderRidesRepository {
  Future<Either<Failure, RiderRide?>> getActiveRiderRide({
    required int? riderId,
  });

  Future<Either<Failure, RiderRide?>> getRiderRideByRideId({
    required int? riderId,
    required String rideId,
  });

  Future<Either<Failure, void>> createReservation({
    required String rideId,
    required int? riderId,
    required String meetingPoint,
    required String destinationPoint,
  });

  Future<Either<Failure, void>> cancelReservation({
    required String reservationId,
  });
}
