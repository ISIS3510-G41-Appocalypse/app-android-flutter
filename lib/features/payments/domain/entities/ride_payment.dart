import 'payment_method.dart';

class RidePayment {
  final int id;
  final String reservationId;
  final String rideId;
  final int driverId;
  final int riderId;
  final int amount;
  final DateTime? deadline;
  final String state;
  final String? type;
  final String driverName;
  final String riderName;
  final String source;
  final String destination;
  final String date;
  final String departureTime;
  final List<PaymentMethod> availableMethods;

  const RidePayment({
    required this.id,
    required this.reservationId,
    required this.rideId,
    required this.driverId,
    required this.riderId,
    required this.amount,
    this.deadline,
    required this.state,
    this.type,
    required this.driverName,
    required this.riderName,
    required this.source,
    required this.destination,
    required this.date,
    required this.departureTime,
    this.availableMethods = const [],
  });

  bool get isPending => state == 'PENDIENTE';
  bool get isWaitingDriverConfirmation => state == 'POR CONFIRMAR';
  bool get isCompleted => state == 'COMPLETADO';
}
