import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/ride_map_repository.dart';

class IsRideMapLocationSharingEnabled {
  final RideMapRepository repository;

  const IsRideMapLocationSharingEnabled(this.repository);

  Future<Either<Failure, bool>> call({
    required String rideId,
    required int userId,
  }) {
    return repository.isUserLocationSharingEnabled(
      rideId: rideId,
      userId: userId,
    );
  }
}
