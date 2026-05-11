class DriverRideReservation {
  final String reservationId;
  final int riderId;
  final int riderUserId;
  final String riderName;
  final double rating;
  final double cancellationOdds;
  final String state;

  const DriverRideReservation({
    required this.reservationId,
    required this.riderId,
    required this.riderUserId,
    required this.riderName,
    required this.rating,
    required this.cancellationOdds,
    required this.state,
  });
}
