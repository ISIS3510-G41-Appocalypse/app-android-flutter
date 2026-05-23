abstract class PaymentsRemoteDataSource {
  Future<List<Map<String, dynamic>>> getDriverRidesWithPayments({
    required int driverId,
  });

  Future<List<Map<String, dynamic>>> getDriverPaymentsForRide({
    required int driverId,
    required String rideId,
  });

  Future<List<Map<String, dynamic>>> getRiderRidesWithPayments({
    required int riderId,
  });

  Future<List<Map<String, dynamic>>> getRiderPaymentsForRide({
    required int riderId,
    required String rideId,
  });

  Future<List<Map<String, dynamic>>> getPaymentsByReservationIds({
    required List<String> reservationIds,
  });

  Future<void> createPayment({
    required String reservationId,
    required int amount,
    required int driverId,
    required int riderId,
    required String type,
    required DateTime deadline,
  });

  Future<void> updatePayment({
    required int paymentId,
    required String state,
    String? type,
  });
}
