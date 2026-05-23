import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/cancel_reservation.dart';
import '../../domain/usecases/get_active_rider_ride.dart';
import '../../domain/usecases/get_rider_ride_by_ride_id.dart';
import 'rider_rides_state.dart';

class RiderRidesCubit extends Cubit<RiderRidesState> {
  final GetActiveRiderRide getActiveRiderRide;
  final GetRiderRideByRideId getRiderRideByRideId;
  final CancelReservation cancelReservationUseCase;
  int? _lastRiderId;

  RiderRidesCubit({
    required this.getActiveRiderRide,
    required this.getRiderRideByRideId,
    required this.cancelReservationUseCase,
  }) : super(RiderRidesState.initial());

  Future<void> loadActiveRide({
    required int? riderId,
    bool showLoading = true,
  }) async {
    _lastRiderId = riderId;
    final hasVisibleRide =
        state.status == RiderRidesStatus.success && state.ride != null;

    if (showLoading || !hasVisibleRide) {
      emit(
        state.copyWith(
          status: RiderRidesStatus.loading,
          message: null,
          isOffline: false,
          isCancelling: false,
          ratingPrompt: null,
        ),
      );
    }

    final result = await getActiveRiderRide(riderId: riderId);

    result.fold(
      (failure) {
        if (hasVisibleRide && !showLoading) {
          emit(
            state.copyWith(
              message: failure.message,
              isOffline: failure is NetworkFailure,
              isCancelling: false,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: RiderRidesStatus.error,
            ride: null,
            message: failure.message,
            isOffline: failure is NetworkFailure,
            isCancelling: false,
            ratingPrompt: null,
          ),
        );
      },
      (ride) {
        if (ride == null) {
          emit(
            state.copyWith(
              status: RiderRidesStatus.empty,
              ride: null,
              message: 'Aun no tienes una reserva activa como pasajero.',
              isOffline: false,
              isCancelling: false,
              ratingPrompt: null,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: RiderRidesStatus.success,
            ride: ride,
            message: null,
            isOffline: false,
            isCancelling: false,
            ratingPrompt: null,
          ),
        );
      },
    );
  }

  Future<void> reloadActiveRide() async {
    final currentRide = state.ride;

    if (currentRide != null && currentRide.state != 'FINALIZADA') {
      await _loadRideByKnownRideId(
        riderId: _lastRiderId,
        rideId: currentRide.rideId,
        previousRideState: currentRide.state,
        showLoading: false,
      );
      return;
    }

    await loadActiveRide(riderId: _lastRiderId, showLoading: false);
  }

  Future<void> completeRatingPrompt() async {
    emit(state.copyWith(ratingPrompt: null));
    await loadActiveRide(riderId: _lastRiderId);
  }

  Future<void> cancelReservation() async {
    final currentRide = state.ride;

    if (currentRide == null || state.isCancelling) {
      return;
    }

    if (!_canCancelReservation(currentRide.state)) {
      emit(
        state.copyWith(
          message: 'Esta reserva ya no se puede cancelar desde la app.',
          isOffline: false,
          isCancelling: false,
        ),
      );
      return;
    }

    emit(state.copyWith(message: null, isOffline: false, isCancelling: true));

    final result = await cancelReservationUseCase(
      reservationId: currentRide.reservationId,
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            message: failure.message,
            isOffline: failure is NetworkFailure,
            isCancelling: false,
          ),
        );
      },
      (_) async {
        await reloadActiveRide();
      },
    );
  }

  bool _canCancelReservation(String state) {
    return state == 'PENDIENTE' || state == 'ACEPTADA';
  }

  Future<void> _loadRideByKnownRideId({
    required int? riderId,
    required String rideId,
    required String previousRideState,
    bool showLoading = true,
  }) async {
    final hasVisibleRide =
        state.status == RiderRidesStatus.success && state.ride != null;

    if (showLoading || !hasVisibleRide) {
      emit(
        state.copyWith(
          status: RiderRidesStatus.loading,
          message: null,
          isOffline: false,
          isCancelling: false,
        ),
      );
    }

    final result = await getRiderRideByRideId(riderId: riderId, rideId: rideId);

    result.fold(
      (failure) {
        if (hasVisibleRide && !showLoading) {
          emit(
            state.copyWith(
              message: failure.message,
              isOffline: failure is NetworkFailure,
              isCancelling: false,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: RiderRidesStatus.error,
            ride: null,
            message: failure.message,
            isOffline: failure is NetworkFailure,
            isCancelling: false,
          ),
        );
      },
      (ride) {
        if (ride == null) {
          emit(
            state.copyWith(
              status: RiderRidesStatus.empty,
              ride: null,
              message: 'Aun no tienes una reserva activa como pasajero.',
              isOffline: false,
              isCancelling: false,
              ratingPrompt: null,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: RiderRidesStatus.success,
            ride: ride,
            message: null,
            isOffline: false,
            isCancelling: false,
            ratingPrompt:
                previousRideState != 'FINALIZADA' && ride.state == 'FINALIZADA'
                ? RiderRatingPrompt(
                    rideId: ride.rideId,
                    riderId: riderId ?? 0,
                    driverId: ride.driverId,
                    driverName: ride.driverName.isEmpty
                        ? 'Conductor'
                        : ride.driverName,
                  )
                : null,
          ),
        );
      },
    );
  }
}
