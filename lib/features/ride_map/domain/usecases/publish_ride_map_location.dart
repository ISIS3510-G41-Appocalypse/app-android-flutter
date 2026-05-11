import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/ride_map_repository.dart';

class PublishRideMapLocation {
  final RideMapRepository repository;

  const PublishRideMapLocation(this.repository);

  Future<Either<Failure, void>> call({
    required String rideId,
    required int userId,
    required double latitude,
    required double longitude,
  }) {
    return repository.publishUserLocation(
      rideId: rideId,
      userId: userId,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
