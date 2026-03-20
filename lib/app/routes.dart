import 'package:flutter/material.dart';
import '../features/home/presentation/view/pages/home_page.dart';
import '../features/auth/presentation/view/pages/login_page.dart';
import '../features/home/presentation/view/pages/test_session_page.dart';
import '../features/nav/presentation/view/pages/main_nav.dart';

class AppRoutes {
  static const String home       = '/home';
  static const String login      = '/login';
  static const String testSession = '/test-session';
  static const String nav        = '/nav';               

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case testSession:
        return MaterialPageRoute(builder: (_) => const TestSessionPage());
      case nav:
        return MaterialPageRoute(builder: (_) => const MainNav()); // ← apunta a MainNav
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}