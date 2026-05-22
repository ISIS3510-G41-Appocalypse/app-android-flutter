import '../../domain/entities/driver_ride.dart';
import '../../../ratings/domain/entities/rating_passenger.dart';

enum DriverRidesStatus { initial, loading, success, empty, error }

class DriverRatingPrompt {
  final String rideId;
  final int driverId;
  final List<RatingPassenger> passengers;

  const DriverRatingPrompt({
    required this.rideId,
    required this.driverId,
    required this.passengers,
  });
}

class DriverRidesState {
  static const Object _sentinel = Object();

  final DriverRidesStatus status;
  final DriverRide? ride;
  final String? message;
  final bool isOffline;
  final bool isUpdating;
  final String? updatingAction;
  final String? updatingReservationId;
  final DriverRatingPrompt? ratingPrompt;

  const DriverRidesState({
    required this.status,
    required this.ride,
    this.message,
    required this.isOffline,
    required this.isUpdating,
    this.updatingAction,
    this.updatingReservationId,
    this.ratingPrompt,
  });

  factory DriverRidesState.initial() {
    return const DriverRidesState(
      status: DriverRidesStatus.initial,
      ride: null,
      message: null,
      isOffline: false,
      isUpdating: false,
      updatingAction: null,
      updatingReservationId: null,
      ratingPrompt: null,
    );
  }

  DriverRidesState copyWith({
    DriverRidesStatus? status,
    Object? ride = _sentinel,
    Object? message = _sentinel,
    bool? isOffline,
    bool? isUpdating,
    Object? updatingAction = _sentinel,
    Object? updatingReservationId = _sentinel,
    Object? ratingPrompt = _sentinel,
  }) {
    return DriverRidesState(
      status: status ?? this.status,
      ride: identical(ride, _sentinel) ? this.ride : ride as DriverRide?,
      message: identical(message, _sentinel)
          ? this.message
          : message as String?,
      isOffline: isOffline ?? this.isOffline,
      isUpdating: isUpdating ?? this.isUpdating,
      updatingAction: identical(updatingAction, _sentinel)
          ? this.updatingAction
          : updatingAction as String?,
      updatingReservationId: identical(updatingReservationId, _sentinel)
          ? this.updatingReservationId
          : updatingReservationId as String?,
      ratingPrompt: identical(ratingPrompt, _sentinel)
          ? this.ratingPrompt
          : ratingPrompt as DriverRatingPrompt?,
    );
  }
}
