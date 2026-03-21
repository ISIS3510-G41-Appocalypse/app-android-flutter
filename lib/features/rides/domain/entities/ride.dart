class Ride {
  final int?   id;
  final int    driverId;
  final int    vehicleId;
  final int    zoneId;
  final String source;
  final String destination;
  final String date;
  final String departureTime;
  final String state;
  final String type;
  final double price;

  const Ride({
    this.id,
    required this.driverId,
    required this.vehicleId,
    required this.zoneId,
    required this.source,
    required this.destination,
    required this.date,
    required this.departureTime,
    required this.state,
    required this.type,
    required this.price,
  });
}