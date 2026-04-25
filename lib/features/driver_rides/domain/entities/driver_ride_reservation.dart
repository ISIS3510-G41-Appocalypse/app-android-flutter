class DriverRideReservation {
  final String reservationId;
  final int riderId;
  final String riderName;
  final double rating;
  final double cancellationOdds;
  final String state;

  const DriverRideReservation({
    required this.reservationId,
    required this.riderId,
    required this.riderName,
    required this.rating,
    required this.cancellationOdds,
    required this.state,
  });
}
