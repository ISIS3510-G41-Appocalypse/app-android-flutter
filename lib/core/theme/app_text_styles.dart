import 'package:flutter/material.dart';

class AppTextStyles {
  // Usando fuentes del sistema (sin dependencia de internet)
  static TextStyle get primary => const TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
  );
  
  static TextStyle get secondary => const TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
  );
}