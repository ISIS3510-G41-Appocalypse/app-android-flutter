class RideOffer {
  final String id;
  final String driverName;
  final double driverRating;
  final int tripsCount;
  final int price;
  final String source;
  final String destination;
  final DateTime departureDateTime;
  final int availableSeats;
  final String carModel;
  final String zoneName;
  final String tripType;

  const RideOffer({
    required this.id,
    required this.driverName,
    required this.driverRating,
    required this.tripsCount,
    required this.price,
    required this.source,
    required this.destination,
    required this.departureDateTime,
    required this.availableSeats,
    required this.carModel,
    required this.zoneName,
    required this.tripType,
  });
}
