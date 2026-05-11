import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'app/app.dart';
import 'core/platform/app_orientation.dart';
import 'injection/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppOrientation.lockPortrait();
  await dotenv.load(fileName: ".env");
  final mapboxToken =
      dotenv.env['MAPBOX_ACCESS_TOKEN'] ??
      const String.fromEnvironment('ACCESS_TOKEN');
  if (mapboxToken.isNotEmpty) {
    MapboxOptions.setAccessToken(mapboxToken);
  }
  await setupLocator();
  runApp(const MyApp());
}
