import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/driver_rides_repository.dart';

class RejectReservation {
  final DriverRidesRepository repository;

  RejectReservation(this.repository);

  Future<Either<Failure, void>> call({required String reservationId}) {
    return repository.rejectReservation(reservationId: reservationId);
  }
}
