import 'package:flutter/material.dart';
import 'app_dependencies.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Happy Ride',
      onGenerateRoute: AppRoutes.onGenerateRoute,
      builder: (context, child) {
        return AppDependencies(child: child!);
      },
    );
  }
}