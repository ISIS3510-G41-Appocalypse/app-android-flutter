import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/payments_snapshot.dart';
import '../repositories/payments_repository.dart';

class GetDriverPayments {
  final PaymentsRepository repository;

  GetDriverPayments(this.repository);

  Future<Either<Failure, PaymentsSnapshot>> call({required int? driverId}) {
    return repository.getDriverPayments(driverId: driverId);
  }
}
