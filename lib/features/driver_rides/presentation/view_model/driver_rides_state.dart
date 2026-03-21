import '../../domain/entities/driver_ride.dart';

enum DriverRidesStatus { initial, loading, success, empty, error }

class DriverRidesState {
  static const Object _sentinel = Object();

  final DriverRidesStatus status;
  final DriverRide? ride;
  final String? message;

  const DriverRidesState({
    required this.status,
    required this.ride,
    this.message,
  });

  factory DriverRidesState.initial() {
    return const DriverRidesState(
      status: DriverRidesStatus.initial,
      ride: null,
      message: null,
    );
  }

  DriverRidesState copyWith({
    DriverRidesStatus? status,
    Object? ride = _sentinel,
    Object? message = _sentinel,
  }) {
    return DriverRidesState(
      status: status ?? this.status,
      ride: identical(ride, _sentinel) ? this.ride : ride as DriverRide?,
      message: identical(message, _sentinel) ? this.message : message as String?,
    );
  }
}
