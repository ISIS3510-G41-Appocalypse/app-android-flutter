abstract class RideOffersRemoteDataSource {
  Future<List<Map<String, dynamic>>> getRides();

  Future<List<Map<String, dynamic>>> getVehicles();

  Future<List<Map<String, dynamic>>> getDrivers();

  Future<List<Map<String, dynamic>>> getUsers();

  Future<List<Map<String, dynamic>>> getZones();
}
