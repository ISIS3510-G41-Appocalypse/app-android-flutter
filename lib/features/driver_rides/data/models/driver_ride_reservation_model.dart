import '../../../../core/helpers/json_parsers.dart';
import '../../domain/entities/driver_ride_reservation.dart';

class DriverRideReservationModel {
  final String reservationId;
  final int riderId;
  final String riderName;
  final double rating;
  final double cancellationOdds;
  final String state;

  const DriverRideReservationModel({
    required this.reservationId,
    required this.riderId,
    required this.riderName,
    required this.rating,
    required this.cancellationOdds,
    required this.state,
  });

  factory DriverRideReservationModel.fromRows({
    required Map<String, dynamic> reservationRow,
    required Map<String, dynamic> riderRow,
    required Map<String, dynamic>? userRow,
  }) {
    final firstName = userRow?['first_name'] as String? ?? '';
    final lastName = userRow?['last_name'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();

    return DriverRideReservationModel(
      reservationId: reservationRow['id'].toString(),
      riderId: JsonParsers.parseInt(reservationRow['rider_id']),
      riderName: fullName.isEmpty ? 'Pasajero' : fullName,
      rating: JsonParsers.parseDouble(riderRow['rating']),
      cancellationOdds: JsonParsers.parseDouble(riderRow['cancellation_odds']),
      state: reservationRow['state'] as String? ?? '',
    );
  }

  DriverRideReservation toEntity() {
    return DriverRideReservation(
      reservationId: reservationId,
      riderId: riderId,
      riderName: riderName,
      rating: rating,
      cancellationOdds: cancellationOdds,
      state: state,
    );
  }
}
