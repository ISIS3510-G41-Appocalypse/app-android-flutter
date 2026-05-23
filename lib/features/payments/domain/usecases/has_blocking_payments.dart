import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/payments_repository.dart';

class HasBlockingPayments {
  final PaymentsRepository repository;

  HasBlockingPayments(this.repository);

  Future<Either<Failure, bool>> call({required int? riderId}) {
    return repository.hasBlockingPayments(riderId: riderId);
  }
}
