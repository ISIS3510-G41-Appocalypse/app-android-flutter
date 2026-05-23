import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ride_payment.dart';
import '../repositories/payments_repository.dart';

class GetDriverPayments {
  final PaymentsRepository repository;

  GetDriverPayments(this.repository);

  Future<Either<Failure, List<RidePayment>>> call({required int? driverId}) {
    return repository.getDriverPayments(driverId: driverId);
  }
}
