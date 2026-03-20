import '../../domain/entities/vehicle.dart';

class VehicleModel extends Vehicle {
  const VehicleModel({
    required super.id,
    required super.brand,
    required super.model,
    required super.color,
    required super.licensePlate,
    required super.numberSlots,
    required super.driverId,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        id:json['id'] as int,
        brand:json['brand'] as String,
        model:json['model'] as String,
        color:json['color'] as String,
        licensePlate:json['license_plate'] as String,
        numberSlots:json['number_slots'] as int,
        driverId:json['driver_id'] as int,
      );
}