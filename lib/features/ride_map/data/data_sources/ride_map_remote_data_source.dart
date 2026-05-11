abstract class RideMapRemoteDataSource {
  Future<List<Map<String, dynamic>>> getRideLocationRows({
    required String rideId,
    required List<int> userIds,
  });

  Future<void> createUserLocation({
    required String rideId,
    required int userId,
    required double latitude,
    required double longitude,
  });
}
