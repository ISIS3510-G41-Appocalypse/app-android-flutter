abstract class DriverRidesRemoteDataSource {
  Future<Map<String, dynamic>?> getActiveDriverRideRow({required int driverId});

  Future<Map<String, dynamic>?> getRideRow({required String rideId});

  Future<Map<String, dynamic>> getVehicleRow({required int vehicleId});

  Future<List<Map<String, dynamic>>> getReservationRows({
    required String rideId,
  });

  Future<List<Map<String, dynamic>>> getRiderRows({
    required List<int> riderIds,
  });

  Future<List<Map<String, dynamic>>> getUserRows({required List<int> userIds});

  Future<Map<String, dynamic>> updateRideState({
    required String rideId,
    required String state,
  });

  Future<Map<String, dynamic>> updateReservationState({
    required String reservationId,
    required String state,
  });

  Future<void> updateReservationStatesByRide({
    required String rideId,
    required List<String> currentStates,
    required String nextState,
  });
}
