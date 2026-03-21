import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/driver_rides_repository.dart';

class UpdateRideState {
  final DriverRidesRepository repository;

  UpdateRideState(this.repository);

  Future<Either<Failure, void>> call({
    required String rideId,
    required String state,
  }) {
    return repository.updateRideState(rideId: rideId, state: state);
  }
}
