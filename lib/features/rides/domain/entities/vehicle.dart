class Vehicle {
  final int    id;
  final String brand;
  final String model;
  final String color;
  final String licensePlate;
  final int    numberSlots;
  final int    driverId;

  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.color,
    required this.licensePlate,
    required this.numberSlots,
    required this.driverId,
  });

  String get infoCarro => '$brand $model · $licensePlate';

  int get puestosDisponibles => numberSlots - 1;
}