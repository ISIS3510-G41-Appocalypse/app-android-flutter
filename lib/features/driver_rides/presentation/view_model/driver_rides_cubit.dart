import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/driver_ride.dart';
import '../../domain/usecases/accept_reservation.dart';
import '../../domain/usecases/get_active_driver_ride.dart';
import '../../domain/usecases/reject_reservation.dart';
import '../../domain/usecases/update_ride_state.dart';
import 'driver_rides_state.dart';

class DriverRidesCubit extends Cubit<DriverRidesState> {
  static const Duration _startWindowOffset = Duration(minutes: 5);

  final GetActiveDriverRide getActiveDriverRide;
  final UpdateRideState updateRideState;
  final AcceptReservation acceptReservationUseCase;
  final RejectReservation rejectReservationUseCase;
  int? _lastDriverId;

  DriverRidesCubit({
    required this.getActiveDriverRide,
    required this.updateRideState,
    required this.acceptReservationUseCase,
    required this.rejectReservationUseCase,
  }) : super(DriverRidesState.initial());

  Future<void> loadActiveRide({required int? driverId}) async {
    _lastDriverId = driverId;
    emit(
      state.copyWith(
        status: DriverRidesStatus.loading,
        message: null,
        isOffline: false,
      ),
    );

    final result = await getActiveDriverRide(driverId: driverId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: DriverRidesStatus.error,
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
              status: DriverRidesStatus.empty,
              ride: null,
              message: 'Aun no tienes un viaje activo como conductor.',
              isOffline: false,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: DriverRidesStatus.success,
            ride: ride,
            message: null,
            isOffline: false,
            isUpdating: false,
            updatingAction: null,
            updatingReservationId: null,
          ),
        );
      },
    );
  }

  Future<void> reloadActiveRide() async {
    await loadActiveRide(driverId: _lastDriverId);
  }

  Future<void> startRide() async {
    final currentRide = state.ride;

    if (currentRide == null || state.isUpdating) {
      return;
    }

    final validationMessage = _validateRideCanStart(currentRide);
    if (validationMessage != null) {
      emit(state.copyWith(message: validationMessage));
      return;
    }

    await _changeRideState(nextState: 'EN_CURSO', actionLabel: 'start');
  }

  Future<void> cancelRide() async {
    await _changeRideState(nextState: 'CANCELADO', actionLabel: 'cancel');
  }

  Future<void> finishRide() async {
    await _changeRideState(nextState: 'FINALIZADO', actionLabel: 'finish');
  }

  Future<void> acceptReservation(String reservationId) async {
    final currentRide = state.ride;

    if (currentRide == null || state.isUpdating) {
      return;
    }

    emit(
      state.copyWith(
        isUpdating: true,
        updatingAction: 'accept_reservation',
        updatingReservationId: reservationId,
        message: null,
      ),
    );

    final result = await acceptReservationUseCase(
      rideId: currentRide.id,
      reservationId: reservationId,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isUpdating: false,
            updatingAction: null,
            updatingReservationId: null,
            message: failure.message,
            isOffline: failure is NetworkFailure,
          ),
        );
      },
      (_) async {
        emit(
          state.copyWith(
            isUpdating: false,
            updatingAction: null,
            updatingReservationId: null,
            message: null,
            isOffline: false,
          ),
        );
        await reloadActiveRide();
      },
    );
  }

  Future<void> rejectReservation(String reservationId) async {
    if (state.ride == null || state.isUpdating) {
      return;
    }

    emit(
      state.copyWith(
        isUpdating: true,
        updatingAction: 'reject_reservation',
        updatingReservationId: reservationId,
        message: null,
      ),
    );

    final result = await rejectReservationUseCase(reservationId: reservationId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isUpdating: false,
            updatingAction: null,
            updatingReservationId: null,
            message: failure.message,
            isOffline: failure is NetworkFailure,
          ),
        );
      },
      (_) async {
        emit(
          state.copyWith(
            isUpdating: false,
            updatingAction: null,
            updatingReservationId: null,
            message: null,
            isOffline: false,
          ),
        );
        await reloadActiveRide();
      },
    );
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
            updatingReservationId: null,
            message: failure.message,
            isOffline: failure is NetworkFailure,
          ),
        );
      },
      (_) async {
        emit(
          state.copyWith(
            isUpdating: false,
            updatingAction: null,
            updatingReservationId: null,
            message: null,
            isOffline: false,
          ),
        );
        await reloadActiveRide();
      },
    );
  }

  String? _validateRideCanStart(DriverRide currentRide) {
    if (currentRide.state != 'OFERTADO') {
      return null;
    }

    final departureDateTime = _parseRideDepartureDateTime(currentRide);
    if (departureDateTime == null) {
      return 'No pudimos validar la hora de salida de este viaje.';
    }

    final now = DateTime.now();
    final startAllowedAt = departureDateTime.subtract(_startWindowOffset);

    if (now.isBefore(startAllowedAt)) {
      return 'Podras iniciar este viaje desde las ${_formatTime(startAllowedAt)}.';
    }

    return null;
  }

  DateTime? _parseRideDepartureDateTime(DriverRide currentRide) {
    final dateParts = currentRide.date.split('-');
    if (dateParts.length != 3) {
      return null;
    }

    final timeParts = currentRide.departureTime.split(':');
    if (timeParts.length < 2) {
      return null;
    }

    final year = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final day = int.tryParse(dateParts[2]);
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    final second = timeParts.length > 2 ? int.tryParse(timeParts[2]) ?? 0 : 0;

    if (year == null ||
        month == null ||
        day == null ||
        hour == null ||
        minute == null) {
      return null;
    }

    return DateTime(year, month, day, hour, minute, second);
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
