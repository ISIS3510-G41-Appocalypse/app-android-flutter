import '../../../../core/helpers/json_parsers.dart';
import '../../domain/entities/ride_offer.dart';

class RideOfferModel {
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

  const RideOfferModel({
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

  factory RideOfferModel.fromJson(Map<String, dynamic> json) {
    return RideOfferModel(
      id: json['id'].toString(),
      driverName: json['driver_name'] as String,
      driverRating: JsonParsers.parseDouble(json['driver_rating']),
      tripsCount: JsonParsers.parseInt(json['trips_count']),
      price: JsonParsers.parseInt(json['price']),
      source: json['source'] as String,
      destination: json['destination'] as String,
      date: DateTime.parse(json['date'] as String),
      departureTime: json['departure_time'] as String,
      slots: JsonParsers.parseInt(json['slots']),
      carModel: json['car_model'] as String,
      zoneName: json['zone_name'] as String,
      type: json['type'] as String,
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
      date: date,
      departureTime: departureTime,
      slots: slots,
      carModel: carModel,
      zoneName: zoneName,
      type: type,
    );
  }

}
