import '../../domain/entities/driver_ride.dart';

class DriverRideModel {
  final String id;
  final String source;
  final String destination;
  final String state;
  final String departureTime;
  final int availableSlots;

  const DriverRideModel({
    required this.id,
    required this.source,
    required this.destination,
    required this.state,
    required this.departureTime,
    required this.availableSlots,
  });

  factory DriverRideModel.fromJson(
    Map<String, dynamic> json, {
    required int availableSlots,
  }) {
    return DriverRideModel(
      id: json['id'].toString(),
      source: json['source'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      state: json['state'] as String? ?? '',
      departureTime: json['departure_time'] as String? ?? '',
      availableSlots: availableSlots,
    );
  }

  DriverRide toEntity() {
    return DriverRide(
      id: id,
      source: source,
      destination: destination,
      state: state,
      departureTime: departureTime,
      availableSlots: availableSlots,
    );
  }
}
