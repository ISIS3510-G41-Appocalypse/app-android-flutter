abstract class DriverRidesRemoteDataSource {
  Future<Map<String, dynamic>?> getActiveDriverRideRow({required int driverId});

  Future<Map<String, dynamic>> getVehicleRow({required int vehicleId});
}
