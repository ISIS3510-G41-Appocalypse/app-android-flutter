import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/realtime/supabase_realtime_service.dart';
import '../../domain/usecases/cancel_reservation.dart';
import '../../domain/usecases/get_active_rider_ride.dart';
import '../../domain/usecases/get_rider_ride_by_ride_id.dart';
import 'rider_rides_state.dart';

class RiderRidesCubit extends Cubit<RiderRidesState> {
  final GetActiveRiderRide getActiveRiderRide;
  final GetRiderRideByRideId getRiderRideByRideId;
  final CancelReservation cancelReservationUseCase;
  final SupabaseRealtimeService realtimeService;
  int? _lastRiderId;
  RealtimeSubscription? _activeRideSubscription;
  String? _subscribedRideKey;
  bool _isRealtimeReloadRunning = false;

  RiderRidesCubit({
    required this.getActiveRiderRide,
    required this.getRiderRideByRideId,
    required this.cancelReservationUseCase,
    required this.realtimeService,
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
          _clearRealtimeSubscription();
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

        _syncRealtimeSubscription(
          rideId: ride.rideId,
          reservationId: ride.reservationId,
        );
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

  void _syncRealtimeSubscription({
    required String rideId,
    required String reservationId,
  }) {
    final key = '$rideId|$reservationId';
    if (_subscribedRideKey == key) {
      return;
    }

    _clearRealtimeSubscription();
    _subscribedRideKey = key;
    _activeRideSubscription = realtimeService.watchRiderRide(
      rideId: rideId,
      reservationId: reservationId,
      onChange: _handleRealtimeChange,
    );
  }

  void _handleRealtimeChange() {
    if (_isRealtimeReloadRunning || isClosed) {
      return;
    }

    _isRealtimeReloadRunning = true;
    reloadActiveRide().whenComplete(() {
      _isRealtimeReloadRunning = false;
    });
  }

  void _clearRealtimeSubscription() {
    _activeRideSubscription?.cancel();
    _activeRideSubscription = null;
    _subscribedRideKey = null;
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
        emit(
          state.copyWith(
            message: 'Reserva cancelada.',
            isOffline: false,
            isCancelling: false,
          ),
        );
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
          _clearRealtimeSubscription();
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

        _syncRealtimeSubscription(
          rideId: ride.rideId,
          reservationId: ride.reservationId,
        );
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

  @override
  Future<void> close() {
    _clearRealtimeSubscription();
    return super.close();
  }
}
