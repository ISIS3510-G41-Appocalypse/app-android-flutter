import 'package:app_ios_flutter/features/ride_offers/presentation/view/pages/ride_offers_page.dart';
import 'package:flutter/material.dart';
import '../features/home/presentation/view/pages/home_page.dart';
import '../features/auth/presentation/view/pages/login_page.dart';
import '../features/home/presentation/view/pages/test_session_page.dart';
import '../features/auth/presentation/view/widgets/auth_gate.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String testSession = '/test-session';
  static const String rideOffers = '/ride-offers';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (context) => const HomePage());
      case login:
        return MaterialPageRoute(builder: (context) => const LoginPage());
      case testSession:
        return MaterialPageRoute(builder: (context) => const TestSessionPage());
      case rideOffers:
        return MaterialPageRoute(builder:(context) => const RideOffersPage());
      default:
        return MaterialPageRoute(
          builder: (context) => const AuthGate(),
        );
    }
  }
}