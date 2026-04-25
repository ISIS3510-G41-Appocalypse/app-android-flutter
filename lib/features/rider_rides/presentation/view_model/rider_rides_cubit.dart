import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_active_rider_ride.dart';
import 'rider_rides_state.dart';

class RiderRidesCubit extends Cubit<RiderRidesState> {
  final GetActiveRiderRide getActiveRiderRide;
  int? _lastRiderId;

  RiderRidesCubit({required this.getActiveRiderRide})
    : super(RiderRidesState.initial());

  Future<void> loadActiveRide({required int? riderId}) async {
    _lastRiderId = riderId;
    emit(
      state.copyWith(
        status: RiderRidesStatus.loading,
        message: null,
        isOffline: false,
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
          ),
        );
      },
    );
  }

  Future<void> reloadActiveRide() async {
    await loadActiveRide(riderId: _lastRiderId);
  }
}
