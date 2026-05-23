import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/payments_snapshot.dart';
import '../repositories/payments_repository.dart';

class GetRiderPayments {
  final PaymentsRepository repository;

  GetRiderPayments(this.repository);

  Future<Either<Failure, PaymentsSnapshot>> call({required int? riderId}) {
    return repository.getRiderPayments(riderId: riderId);
  }
}
