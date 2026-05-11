import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/rider_rides_repository.dart';

class CancelReservation {
  final RiderRidesRepository repository;

  CancelReservation(this.repository);

  Future<Either<Failure, void>> call({required String reservationId}) {
    return repository.cancelReservation(reservationId: reservationId);
  }
}
