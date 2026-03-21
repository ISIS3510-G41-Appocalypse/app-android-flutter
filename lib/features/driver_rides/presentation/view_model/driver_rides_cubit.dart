import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_active_driver_ride.dart';
import '../../domain/usecases/update_ride_state.dart';
import 'driver_rides_state.dart';

class DriverRidesCubit extends Cubit<DriverRidesState> {
  final GetActiveDriverRide getActiveDriverRide;
  final UpdateRideState updateRideState;
  int? _lastDriverId;

  DriverRidesCubit({
    required this.getActiveDriverRide,
    required this.updateRideState,
  })
    : super(DriverRidesState.initial());

  Future<void> loadActiveRide({required int? driverId}) async {
    _lastDriverId = driverId;
    emit(state.copyWith(status: DriverRidesStatus.loading, message: null));

    final result = await getActiveDriverRide(driverId: driverId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: DriverRidesStatus.error,
            ride: null,
            message: failure.message,
          ),
        );
      },
      (ride) {
        if (ride == null) {
          emit(
            state.copyWith(
              status: DriverRidesStatus.empty,
              ride: null,
              message: 'Aun no tienes un viaje activo como conductor.',
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: DriverRidesStatus.success,
            ride: ride,
            message: null,
            isUpdating: false,
            updatingAction: null,
          ),
        );
      },
    );
  }

  Future<void> reloadActiveRide() async {
    await loadActiveRide(driverId: _lastDriverId);
  }

  Future<void> startRide() async {
    await _changeRideState(nextState: 'EN_CURSO', actionLabel: 'start');
  }

  Future<void> cancelRide() async {
    await _changeRideState(nextState: 'CANCELADO', actionLabel: 'cancel');
  }

  Future<void> _changeRideState({
    required String nextState,
    required String actionLabel,
  }) async {
    final currentRide = state.ride;

    if (currentRide == null || state.isUpdating) {
      return;
    }

    emit(
      state.copyWith(
        isUpdating: true,
        updatingAction: actionLabel,
        message: null,
      ),
    );

    final result = await updateRideState(
      rideId: currentRide.id,
      state: nextState,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isUpdating: false,
            updatingAction: null,
            message: failure.message,
          ),
        );
      },
      (_) async {
        emit(
          state.copyWith(
            isUpdating: false,
            updatingAction: null,
            message: null,
          ),
        );
        await reloadActiveRide();
      },
    );
  }
}
