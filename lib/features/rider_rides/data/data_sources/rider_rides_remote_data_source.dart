abstract class RiderRidesRemoteDataSource {
  Future<Map<String, dynamic>?> getActiveReservationRow({required int riderId});

  Future<Map<String, dynamic>?> getRideOfferRow({required String rideId});

  Future<Map<String, dynamic>?> getRideRow({required String rideId});

  Future<Map<String, dynamic>?> getDriverRow({required int driverId});

  Future<Map<String, dynamic>> updateReservationState({
    required String reservationId,
    required String state,
  });

  Future<void> createReservationRow({
    required String rideId,
    required int riderId,
    required String meetingPoint,
    required String destinationPoint,
  });
}
