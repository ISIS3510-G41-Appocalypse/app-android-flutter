import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/usecases/get_active_reservation_for_rider.dart';

part 'reservation_state.dart';

class ReservationCubit extends Cubit<ReservationState> {
  final GetActiveReservationForRider getActiveReservationForRider;

  ReservationCubit({required this.getActiveReservationForRider}) : super(ReservationInitial());

  Future<void> fetchActiveReservation(int riderId) async {
    emit(ReservationLoading());
    try {
      final reservation = await getActiveReservationForRider(riderId);
      if (reservation != null) {
        emit(ReservationLoaded(reservation));
      } else {
        emit(ReservationEmpty());
      }
    } catch (e) {
      emit(ReservationError(e.toString()));
    }
  }
}
