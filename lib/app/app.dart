import 'package:flutter/material.dart';
import 'auth_dependencies.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Happy Ride',
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      builder: (context, child) {
        return AuthDependencies(child: child!);
      },
    );
  }
}