import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/payments_repository.dart';

class RejectPayment {
  final PaymentsRepository repository;

  RejectPayment(this.repository);

  Future<Either<Failure, void>> call({required int paymentId}) {
    return repository.rejectPayment(paymentId: paymentId);
  }
}
