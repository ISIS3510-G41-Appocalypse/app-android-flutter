import '../../domain/entities/driver_ride.dart';
import '../../domain/entities/driver_ride_reservation.dart';

class DriverRideModel {
  final String id;
  final String source;
  final String destination;
  final String date;
  final String state;
  final String departureTime;
  final int price;
  final int availableSlots;
  final List<DriverRideReservation> pendingReservations;
  final List<DriverRideReservation> acceptedReservations;

  const DriverRideModel({
    required this.id,
    required this.source,
    required this.destination,
    required this.date,
    required this.state,
    required this.departureTime,
    required this.price,
    required this.availableSlots,
    required this.pendingReservations,
    required this.acceptedReservations,
  });

  factory DriverRideModel.fromJson(
    Map<String, dynamic> json, {
    required int availableSlots,
    required List<DriverRideReservation> pendingReservations,
    required List<DriverRideReservation> acceptedReservations,
  }) {
    return DriverRideModel(
      id: json['id'].toString(),
      source: json['source'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      date: json['date'] as String? ?? '',
      state: json['state'] as String? ?? '',
      departureTime: json['departure_time'] as String? ?? '',
      price: _toInt(json['price']),
      availableSlots: availableSlots,
      pendingReservations: pendingReservations,
      acceptedReservations: acceptedReservations,
    );
  }

  DriverRide toEntity() {
    return DriverRide(
      id: id,
      source: source,
      destination: destination,
      date: date,
      state: state,
      departureTime: departureTime,
      price: price,
      availableSlots: availableSlots,
      pendingReservations: pendingReservations,
      acceptedReservations: acceptedReservations,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
