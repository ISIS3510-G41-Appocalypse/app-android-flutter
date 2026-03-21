class DriverRide {
  final String id;
  final String source;
  final String destination;
  final String state;
  final String departureTime;
  final int availableSlots;

  const DriverRide({
    required this.id,
    required this.source,
    required this.destination,
    required this.state,
    required this.departureTime,
    required this.availableSlots,
  });
}
