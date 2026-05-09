import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/cancel_reservation.dart';
import '../../domain/usecases/get_active_rider_ride.dart';
import 'rider_rides_state.dart';

class RiderRidesCubit extends Cubit<RiderRidesState> {
  final GetActiveRiderRide getActiveRiderRide;
  final CancelReservation cancelReservationUseCase;
  int? _lastRiderId;

  RiderRidesCubit({
    required this.getActiveRiderRide,
    required this.cancelReservationUseCase,
  }) : super(RiderRidesState.initial());

  Future<void> loadActiveRide({required int? riderId}) async {
    _lastRiderId = riderId;
    emit(
      state.copyWith(
        status: RiderRidesStatus.loading,
        message: null,
        isOffline: false,
        isCancelling: false,
      ),
    );

    final result = await getActiveRiderRide(riderId: riderId);

    result.fold(
      (failure) {
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
          ),
        );
      },
    );
  }

  Future<void> reloadActiveRide() async {
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

    emit(
      state.copyWith(
        message: null,
        isOffline: false,
        isCancelling: true,
      ),
    );

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
}
