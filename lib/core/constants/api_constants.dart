import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  static final String apiKey = dotenv.env['API_KEY'] ?? '';

  static const String authToken = '/auth/v1/token';
  static const String authUser = '/auth/v1/user';

  static const String users = '/rest/v1/users';
  static const String riders = '/rest/v1/riders';
  static const String drivers = '/rest/v1/drivers';
  static const String rides = '/rest/v1/rides';
  static const String vehicles = '/rest/v1/vehicles';
  static const String reservations = '/rest/v1/reservations';
  static const String zones = '/rest/v1/zones';
  static const String payments = '/rest/v1/payments';
  static const String rideOffersView = '/rest/v1/ride_offers_view';
  static const String userSharedLocations = '/rest/v1/user_shared_locations';
  static const String ratesDriver = '/rest/v1/rates_driver';
  static const String ratesRider = '/rest/v1/rates_rider';
  static const String riderDriverRecommendation =
      '/rest/v1/rider_driver_recommendation';
  static const String performanceTimes = '/rest/v1/performance_times';

  static String rpc(String functionName) => '/rest/v1/rpc/$functionName';
}
