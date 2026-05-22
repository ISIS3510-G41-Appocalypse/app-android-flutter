import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/rider_ride.dart';
import '../repositories/rider_rides_repository.dart';

class GetRiderRideByRideId {
  final RiderRidesRepository repository;

  GetRiderRideByRideId(this.repository);

  Future<Either<Failure, RiderRide?>> call({
    required int? riderId,
    required String rideId,
  }) {
    return repository.getRiderRideByRideId(riderId: riderId, rideId: rideId);
  }
}
