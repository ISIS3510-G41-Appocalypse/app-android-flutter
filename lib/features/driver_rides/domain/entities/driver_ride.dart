import 'driver_ride_reservation.dart';

class DriverRide {
  final String id;
  final String source;
  final String destination;
  final String date;
  final String state;
  final String departureTime;
  final int availableSlots;
  final List<DriverRideReservation> pendingReservations;
  final List<DriverRideReservation> acceptedReservations;

  const DriverRide({
    required this.id,
    required this.source,
    required this.destination,
    required this.date,
    required this.state,
    required this.departureTime,
    required this.availableSlots,
    required this.pendingReservations,
    required this.acceptedReservations,
  });
}
