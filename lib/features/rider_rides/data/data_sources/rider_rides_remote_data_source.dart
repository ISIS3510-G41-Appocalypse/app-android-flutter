abstract class RiderRidesRemoteDataSource {
  Future<Map<String, dynamic>?> getActiveReservationRow({required int riderId});

  Future<Map<String, dynamic>?> getRideOfferRow({required String rideId});

  Future<void> createReservationRow({
    required String rideId,
    required int riderId,
    required String meetingPoint,
    required String destinationPoint,
  });
}
