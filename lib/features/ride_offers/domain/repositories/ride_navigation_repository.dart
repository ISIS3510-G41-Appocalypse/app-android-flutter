abstract class RideNavigationRepository {
  Future<void> startRideNavigation({
    required String source,
    required String destination,
  });
}