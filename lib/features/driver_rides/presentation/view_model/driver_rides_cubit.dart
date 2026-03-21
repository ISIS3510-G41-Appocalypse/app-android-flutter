import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_active_driver_ride.dart';
import 'driver_rides_state.dart';

class DriverRidesCubit extends Cubit<DriverRidesState> {
  final GetActiveDriverRide getActiveDriverRide;

  DriverRidesCubit({required this.getActiveDriverRide})
    : super(DriverRidesState.initial());

  Future<void> loadActiveRide({required int? driverId}) async {
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
          ),
        );
      },
    );
  }
}
