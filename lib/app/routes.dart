import 'package:app_ios_flutter/features/ride_offers/presentation/view/pages/ride_offers_page.dart';
import 'package:app_ios_flutter/features/rides/presentation/view/pages/create_ride_page.dart';
import 'package:flutter/material.dart';
import '../features/home/presentation/view/pages/home_page.dart';
import '../features/auth/presentation/view/pages/login_page.dart';
import '../features/home/presentation/view/pages/profile_page.dart';
import '../features/auth/presentation/view/widgets/auth_gate.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String createRide = '/create-ride';               
  static const String rideOffers = '/ride-offers';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case createRide:
        return MaterialPageRoute(builder: (_) => const CreateRidePage()); 
      case rideOffers:
        return MaterialPageRoute(builder:(context) => const RideOffersPage());
      default:
        return MaterialPageRoute(
          builder: (context) => const AuthGate(),
        );
    }
  }
}