import '../../domain/entities/ride_map_location.dart';

enum RideMapStatus { initial, loading, success, empty, error }

class RideMapState {
  final RideMapStatus status;
  final List<RideMapLocation> locations;
  final double? driverLatitude;
  final double? driverLongitude;
  final String? message;
  final bool isOffline;
  final bool isPermissionBlocked;

  const RideMapState({
    required this.status,
    required this.locations,
    this.driverLatitude,
    this.driverLongitude,
    this.message,
    required this.isOffline,
    required this.isPermissionBlocked,
  });

  factory RideMapState.initial() {
    return const RideMapState(
      status: RideMapStatus.initial,
      locations: [],
      isOffline: false,
      isPermissionBlocked: false,
    );
  }

  RideMapState copyWith({
    RideMapStatus? status,
    List<RideMapLocation>? locations,
    double? driverLatitude,
    double? driverLongitude,
    String? message,
    bool clearMessage = false,
    bool? isOffline,
    bool? isPermissionBlocked,
  }) {
    return RideMapState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
      driverLatitude: driverLatitude ?? this.driverLatitude,
      driverLongitude: driverLongitude ?? this.driverLongitude,
      message: clearMessage ? null : message ?? this.message,
      isOffline: isOffline ?? this.isOffline,
      isPermissionBlocked: isPermissionBlocked ?? this.isPermissionBlocked,
    );
  }
}
