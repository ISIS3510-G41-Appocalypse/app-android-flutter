class RideOffer {
  final String id;
  final String driverName;
  final double driverRating;
  final int tripsCount;
  final int price;
  final String source;
  final String destination;
  final DateTime date;
  final String departureTime;
  final int slots;
  final String carModel;
  final String zoneName;
  final String type;

  const RideOffer({
    required this.id,
    required this.driverName,
    required this.driverRating,
    required this.tripsCount,
    required this.price,
    required this.source,
    required this.destination,
    required this.date,
    required this.departureTime,
    required this.slots,
    required this.carModel,
    required this.zoneName,
    required this.type,
  });
}
