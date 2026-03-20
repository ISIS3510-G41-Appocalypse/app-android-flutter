import 'package:flutter/material.dart';
import '../features/home/presentation/view/pages/home_page.dart';

class AppRoutes {
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomePage(),
      };
}