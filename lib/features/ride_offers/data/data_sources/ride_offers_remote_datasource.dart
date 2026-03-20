abstract class RideOffersRemoteDataSource {
  Future<List<Map<String, dynamic>>> getRideOffersRows();

  Future<List<Map<String, dynamic>>> getZonesRows();
}
