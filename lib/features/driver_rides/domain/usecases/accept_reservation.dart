import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/driver_rides_repository.dart';

class AcceptReservation {
  final DriverRidesRepository repository;

  AcceptReservation(this.repository);

  Future<Either<Failure, void>> call({
    required String rideId,
    required String reservationId,
  }) {
    return repository.acceptReservation(
      rideId: rideId,
      reservationId: reservationId,
    );
  }
}
