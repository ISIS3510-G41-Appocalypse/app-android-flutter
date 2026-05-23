import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/payments_repository.dart';

class CreatePendingPaymentsForRide {
  final PaymentsRepository repository;

  CreatePendingPaymentsForRide(this.repository);

  Future<Either<Failure, void>> call({
    required String rideId,
    required int driverId,
    required int amount,
    required List<({String reservationId, int riderId})> passengers,
  }) {
    return repository.createPendingPaymentsForRide(
      rideId: rideId,
      driverId: driverId,
      amount: amount,
      passengers: passengers,
    );
  }
}
