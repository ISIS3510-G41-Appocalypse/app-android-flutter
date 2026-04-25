import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/rider_ride.dart';
import '../repositories/rider_rides_repository.dart';

class GetActiveRiderRide {
  final RiderRidesRepository repository;

  GetActiveRiderRide(this.repository);

  Future<Either<Failure, RiderRide?>> call({required int? riderId}) {
    return repository.getActiveRiderRide(riderId: riderId);
  }
}
