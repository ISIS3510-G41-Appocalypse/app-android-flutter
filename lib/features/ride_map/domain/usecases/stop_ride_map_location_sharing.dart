import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/ride_map_repository.dart';

class StopRideMapLocationSharing {
  final RideMapRepository repository;

  const StopRideMapLocationSharing(this.repository);

  Future<Either<Failure, void>> call({
    required String rideId,
    required int userId,
  }) {
    return repository.stopUserLocationSharing(rideId: rideId, userId: userId);
  }
}
