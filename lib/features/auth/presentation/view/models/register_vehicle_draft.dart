import 'package:flutter/material.dart';

class RegisterVehicleDraft {
  RegisterVehicleDraft()
    : brandController = TextEditingController(),
      modelController = TextEditingController(),
      colorController = TextEditingController(),
      plateController = TextEditingController(),
      seatsController = TextEditingController(text: '4');

  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController colorController;
  final TextEditingController plateController;
  final TextEditingController seatsController;

  void dispose() {
    brandController.dispose();
    modelController.dispose();
    colorController.dispose();
    plateController.dispose();
    seatsController.dispose();
  }
}
