import '../../domain/entities/rider_ride.dart';

enum RiderRidesStatus { initial, loading, success, empty, error }

class RiderRidesState {
  static const Object _sentinel = Object();

  final RiderRidesStatus status;
  final RiderRide? ride;
  final String? message;
  final bool isOffline;
  final bool isCancelling;

  const RiderRidesState({
    required this.status,
    required this.ride,
    this.message,
    required this.isOffline,
    required this.isCancelling,
  });

  factory RiderRidesState.initial() {
    return const RiderRidesState(
      status: RiderRidesStatus.initial,
      ride: null,
      message: null,
      isOffline: false,
      isCancelling: false,
    );
  }

  RiderRidesState copyWith({
    RiderRidesStatus? status,
    Object? ride = _sentinel,
    Object? message = _sentinel,
    bool? isOffline,
    bool? isCancelling,
  }) {
    return RiderRidesState(
      status: status ?? this.status,
      ride: identical(ride, _sentinel) ? this.ride : ride as RiderRide?,
      message: identical(message, _sentinel)
          ? this.message
          : message as String?,
      isOffline: isOffline ?? this.isOffline,
      isCancelling: isCancelling ?? this.isCancelling,
    );
  }
}
