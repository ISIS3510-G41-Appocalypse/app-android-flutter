import '../models/reservation_model.dart';

abstract class ReservationRemoteDataSource {
  Future<ReservationModel?> getActiveReservationForRider(int riderId);
}
