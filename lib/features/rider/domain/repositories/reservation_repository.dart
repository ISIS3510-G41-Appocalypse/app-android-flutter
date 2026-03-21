import '../../domain/entities/reservation.dart';

abstract class ReservationRepository {
  Future<Reservation?> getActiveReservationForRider(int riderId);
}
