import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/payments_snapshot.dart';

abstract class PaymentsRepository {
  Future<Either<Failure, PaymentsSnapshot>> getRiderPayments({
    required int? riderId,
  });

  Future<Either<Failure, PaymentsSnapshot>> getDriverPayments({
    required int? driverId,
  });

  Future<Either<Failure, bool>> hasBlockingPayments({required int? riderId});

  Future<Either<Failure, void>> createPendingPaymentsForRide({
    required String rideId,
    required int driverId,
    required int amount,
    required List<({String reservationId, int riderId})> passengers,
  });

  Future<Either<Failure, void>> markPaymentForConfirmation({
    required int paymentId,
    required String paymentType,
  });

  Future<Either<Failure, void>> confirmPayment({required int paymentId});

  Future<Either<Failure, void>> rejectPayment({required int paymentId});
}
