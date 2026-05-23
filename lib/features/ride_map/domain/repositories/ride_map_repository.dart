import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ride_map_location.dart';

abstract class RideMapRepository {
  Future<Either<Failure, List<RideMapLocation>>> getRideLocations({
    required String rideId,
    required Map<int, String> passengerNamesByUserId,
    double? originLatitude,
    double? originLongitude,
  });

  Future<Either<Failure, void>> publishUserLocation({
    required String rideId,
    required int userId,
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, void>> stopUserLocationSharing({
    required String rideId,
    required int userId,
  });

  Future<Either<Failure, bool>> isUserLocationSharingEnabled({
    required String rideId,
    required int userId,
  });
}
