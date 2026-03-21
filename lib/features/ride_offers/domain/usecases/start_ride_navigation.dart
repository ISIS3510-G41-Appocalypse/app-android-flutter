import '../repositories/ride_navigation_repository.dart';

class StartRideNavigation {
  final RideNavigationRepository repository;

  StartRideNavigation(this.repository);

  Future<void> call({
    required String source,
    required String destination,
  }) {
    return repository.startRideNavigation(
      source: source,
      destination: destination,
    );
  }
}