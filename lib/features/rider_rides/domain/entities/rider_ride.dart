class RiderRide {
  final String reservationId;
  final String rideId;
  final String driverName;
  final int price;
  final String source;
  final String destination;
  final String meetingPoint;
  final String destinationPoint;
  final DateTime date;
  final String departureTime;
  final String state;
  final String carModel;

  const RiderRide({
    required this.reservationId,
    required this.rideId,
    required this.driverName,
    required this.price,
    required this.source,
    required this.destination,
    required this.meetingPoint,
    required this.destinationPoint,
    required this.date,
    required this.departureTime,
    required this.state,
    required this.carModel,
  });
}
