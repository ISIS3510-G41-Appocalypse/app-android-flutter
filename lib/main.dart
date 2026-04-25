import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';
import 'core/platform/app_orientation.dart';
import 'injection/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppOrientation.lockPortrait();
  await dotenv.load(fileName: ".env");
  await setupLocator();
  runApp(const MyApp());
}
