import 'package:app_ios_flutter/features/driver_rides/presentation/view/pages/driver_rides_page.dart';
import 'package:app_ios_flutter/features/payments/presentation/view/pages/payments_page.dart';
import 'package:app_ios_flutter/features/ride_offers/presentation/view/pages/ride_offers_page.dart';
import 'package:app_ios_flutter/features/ratings/presentation/view/pages/ratings_page.dart';
import 'package:app_ios_flutter/features/ratings/presentation/view/pages/ratings_page_args.dart';
import 'package:app_ios_flutter/features/rider_rides/presentation/view/pages/rider_rides_page.dart';
import 'package:app_ios_flutter/features/rides/presentation/view/pages/create_ride_page.dart';
import 'package:flutter/material.dart';
import '../features/home/presentation/view/pages/home_page.dart';
import '../features/auth/presentation/view/pages/login_page.dart';
import '../features/auth/presentation/view/pages/register_page.dart';
import '../features/user/presentation/view/pages/profile_page.dart';
import '../features/auth/presentation/view/widgets/auth_gate.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String createRide = '/create-ride';
  static const String profile = '/profile';
  static const String rideOffers = '/ride-offers';
  static const String driverRides = '/driver-rides';
  static const String riderRides = '/rider-rides';
  static const String ratings = '/ratings';
  static const String payments = '/payments';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        final message = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => HomePage(
            sessionMessage: message is String ? message : null,
          ),
        );
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case createRide:
        return MaterialPageRoute(builder: (_) => const CreateRidePage());
      case rideOffers:
        return MaterialPageRoute(builder: (_) => const RideOffersPage());
      case driverRides:
        return MaterialPageRoute(builder: (_) => const DriverRidesPage());
      case riderRides:
        return MaterialPageRoute(builder: (_) => const RiderRidesPage());
      case ratings:
        final args = settings.arguments;
        if (args is RatingsPageArgs) {
          return MaterialPageRoute(builder: (_) => RatingsPage(args: args));
        }
        return MaterialPageRoute(builder: (context) => const AuthGate());
      case payments:
        return MaterialPageRoute(builder: (_) => const PaymentsPage());
      default:
        return MaterialPageRoute(builder: (context) => const AuthGate());
    }
  }
}
