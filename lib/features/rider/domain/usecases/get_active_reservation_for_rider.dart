import '../entities/reservation.dart';
import '../repositories/reservation_repository.dart';

class GetActiveReservationForRider {
  final ReservationRepository repository;

  GetActiveReservationForRider(this.repository);

  Future<Reservation?> call(int riderId) {
    return repository.getActiveReservationForRider(riderId);
  }
}
