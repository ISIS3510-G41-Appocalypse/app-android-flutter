import 'package:url_launcher/url_launcher.dart';

import '../../domain/repositories/ride_navigation_repository.dart';

class RideNavigationRepositoryImpl implements RideNavigationRepository {
  @override
  Future<void> startRideNavigation({
    required String source,
    required String destination,
  }) async {
    final origin = Uri.encodeComponent(source);
    final dest = Uri.encodeComponent(destination);

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=$origin'
      '&destination=$dest'
      '&travelmode=driving',
    );

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw Exception('No se pudo abrir Google Maps');
    }
  }
}