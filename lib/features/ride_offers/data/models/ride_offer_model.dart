import '../../domain/entities/ride_offer.dart';

class RideOfferModel {
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

  const RideOfferModel({
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

  factory RideOfferModel.fromJson(Map<String, dynamic> json) {
    return RideOfferModel(
      id: json['id'].toString(),
      driverName: json['driver_name'] as String,
      driverRating: _toDouble(json['driver_rating']),
      tripsCount: _toInt(json['trips_count']),
      price: _toInt(json['price']),
      source: json['source'] as String,
      destination: json['destination'] as String,
      departureDateTime: DateTime.parse(json['departure_datetime'] as String),
      availableSeats: _toInt(json['available_seats']),
      carModel: json['car_model'] as String,
      zoneName: json['zone_name'] as String,
      tripType: json['trip_type'] as String,
    );
  }

  RideOffer toEntity() {
    return RideOffer(
      id: id,
      driverName: driverName,
      driverRating: driverRating,
      tripsCount: tripsCount,
      price: price,
      source: source,
      destination: destination,
      departureDateTime: departureDateTime,
      availableSeats: availableSeats,
      carModel: carModel,
      zoneName: zoneName,
      tripType: tripType,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
