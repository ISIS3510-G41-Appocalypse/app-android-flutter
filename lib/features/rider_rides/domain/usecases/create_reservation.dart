import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/rider_rides_repository.dart';

class CreateReservation {
  final RiderRidesRepository repository;

  CreateReservation(this.repository);

  Future<Either<Failure, void>> call({
    required String rideId,
    required int? riderId,
    required String meetingPoint,
    required String destinationPoint,
  }) {
    return repository.createReservation(
      rideId: rideId,
      riderId: riderId,
      meetingPoint: meetingPoint,
      destinationPoint: destinationPoint,
    );
  }
}
