import '../../domain/entities/vehicle.dart';
import '../../domain/entities/zone.dart';

abstract class CreateRideState {}

class CreateRideInitial extends CreateRideState {}

class CreateRideLoadingVehicles extends CreateRideState {}

class CreateRideReady extends CreateRideState {
  final List<Vehicle> vehicles;
  final List<Zone>    zones;          
  final Vehicle?      selectedVehicle;
  final Zone?         selectedZone;   
  final bool          isSubmitting;

  CreateRideReady({
    required this.vehicles,
    required this.zones,
    this.selectedVehicle,
    this.selectedZone,
    this.isSubmitting = false,
  });

  CreateRideReady copyWith({
    List<Vehicle>? vehicles,
    List<Zone>?    zones,
    Vehicle?       selectedVehicle,
    Zone?          selectedZone,
    bool?          isSubmitting,
  }) =>
      CreateRideReady(
        vehicles:        vehicles        ?? this.vehicles,
        zones:           zones           ?? this.zones,
        selectedVehicle: selectedVehicle ?? this.selectedVehicle,
        selectedZone:    selectedZone    ?? this.selectedZone,
        isSubmitting:    isSubmitting    ?? this.isSubmitting,
      );
}

class CreateRideSuccess extends CreateRideState {}

class CreateRideError extends CreateRideState {
  final String message;
  CreateRideError(this.message);
}