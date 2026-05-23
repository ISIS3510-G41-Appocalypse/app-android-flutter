import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/payments_repository.dart';

class ConfirmPayment {
  final PaymentsRepository repository;

  ConfirmPayment(this.repository);

  Future<Either<Failure, void>> call({required int paymentId}) {
    return repository.confirmPayment(paymentId: paymentId);
  }
}
