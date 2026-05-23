import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/payments_repository.dart';

class MarkPaymentForConfirmation {
  final PaymentsRepository repository;

  MarkPaymentForConfirmation(this.repository);

  Future<Either<Failure, void>> call({
    required int paymentId,
    required String paymentType,
  }) {
    return repository.markPaymentForConfirmation(
      paymentId: paymentId,
      paymentType: paymentType,
    );
  }
}
