import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ride_payment.dart';
import '../repositories/payments_repository.dart';

class GetRiderPayments {
  final PaymentsRepository repository;

  GetRiderPayments(this.repository);

  Future<Either<Failure, List<RidePayment>>> call({required int? riderId}) {
    return repository.getRiderPayments(riderId: riderId);
  }
}
