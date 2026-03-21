import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/driver_ride.dart';
import '../repositories/driver_rides_repository.dart';

class GetActiveDriverRide {
  final DriverRidesRepository repository;

  GetActiveDriverRide(this.repository);

  Future<Either<Failure, DriverRide?>> call({required int? driverId}) {
    return repository.getActiveDriverRide(driverId: driverId);
  }
}
