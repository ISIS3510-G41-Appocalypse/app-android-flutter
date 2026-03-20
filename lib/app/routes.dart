import 'package:flutter/material.dart';
import '../features/home/presentation/view/pages/home_page.dart';
import '../features/auth/presentation/view/pages/login_page.dart';
import '../features/home/presentation/view/pages/test_session_page.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String testSession = '/test-session';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (context) => const HomePage());
      case login:
        return MaterialPageRoute(builder: (context) => const LoginPage());
      case testSession:
        return MaterialPageRoute(builder: (context) => const TestSessionPage());
      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}