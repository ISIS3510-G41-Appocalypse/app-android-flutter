import '../../domain/entities/vehicle.dart';
import '../../domain/entities/zone.dart';

enum CreateRideStatus {
  initial,
  loading,
  ready,
  submitting,
  syncing,
  success,
  error,
  offlineQueued,
}

class RideFormDraft {
  final int? vehicleId;
  final int? zoneId;
  final String source;
  final String destination;
  final String date;
  final String departureTime;
  final String type;
  final String price;

  const RideFormDraft({
    this.vehicleId,
    this.zoneId,
    required this.source,
    required this.destination,
    required this.date,
    required this.departureTime,
    required this.type,
    required this.price,
  });
}

class CreateRideState {
  final CreateRideStatus status;
  final List<Vehicle> vehicles;
  final List<Zone> zones;
  final Vehicle? selectedVehicle;
  final Zone? selectedZone;
  final String? message;
  final RideFormDraft? restoredDraft;
  final bool shouldAnnounceRestoredDraft;
  final bool hasPendingRideForm;
  final bool navigateToDriverRides;

  const CreateRideState({
    this.status = CreateRideStatus.initial,
    this.vehicles = const [],
    this.zones = const [],
    this.selectedVehicle,
    this.selectedZone,
    this.message,
    this.restoredDraft,
    this.shouldAnnounceRestoredDraft = false,
    this.hasPendingRideForm = false,
    this.navigateToDriverRides = false,
  });

  bool get isLoading => status == CreateRideStatus.loading;
  bool get isSubmitting => status == CreateRideStatus.submitting;
  bool get isSyncing => status == CreateRideStatus.syncing;
  bool get hasLoadedFormData => vehicles.isNotEmpty;
  bool get isReadyLike =>
      status != CreateRideStatus.initial && status != CreateRideStatus.loading;

  CreateRideState copyWith({
    CreateRideStatus? status,
    List<Vehicle>? vehicles,
    List<Zone>? zones,
    Vehicle? selectedVehicle,
    bool clearSelectedVehicle = false,
    Zone? selectedZone,
    bool clearSelectedZone = false,
    String? message,
    bool clearMessage = false,
    RideFormDraft? restoredDraft,
    bool clearRestoredDraft = false,
    bool? shouldAnnounceRestoredDraft,
    bool? hasPendingRideForm,
    bool? navigateToDriverRides,
  }) {
    return CreateRideState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      zones: zones ?? this.zones,
      selectedVehicle: clearSelectedVehicle
          ? null
          : (selectedVehicle ?? this.selectedVehicle),
      selectedZone:
          clearSelectedZone ? null : (selectedZone ?? this.selectedZone),
      message: clearMessage ? null : (message ?? this.message),
      restoredDraft: clearRestoredDraft
          ? null
          : (restoredDraft ?? this.restoredDraft),
      shouldAnnounceRestoredDraft:
          shouldAnnounceRestoredDraft ?? this.shouldAnnounceRestoredDraft,
      hasPendingRideForm: hasPendingRideForm ?? this.hasPendingRideForm,
      navigateToDriverRides:
          navigateToDriverRides ?? this.navigateToDriverRides,
    );
  }
}
