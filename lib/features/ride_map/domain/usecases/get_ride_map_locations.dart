import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ride_map_location.dart';
import '../repositories/ride_map_repository.dart';

class GetRideMapLocations {
  final RideMapRepository repository;

  const GetRideMapLocations(this.repository);

  Future<Either<Failure, List<RideMapLocation>>> call({
    required String rideId,
    required Map<int, String> passengerNamesByUserId,
    double? originLatitude,
    double? originLongitude,
  }) {
    return repository.getRideLocations(
      rideId: rideId,
      passengerNamesByUserId: passengerNamesByUserId,
      originLatitude: originLatitude,
      originLongitude: originLongitude,
    );
  }
}
