import '../../domain/entities/payment_method.dart';
import '../../domain/entities/ride_payment.dart';

class RidePaymentModel extends RidePayment {
  const RidePaymentModel({
    required super.id,
    required super.reservationId,
    required super.rideId,
    required super.driverId,
    required super.riderId,
    required super.amount,
    super.deadline,
    required super.state,
    super.type,
    required super.driverName,
    required super.riderName,
    required super.source,
    required super.destination,
    required super.date,
    required super.departureTime,
    super.availableMethods,
  });

  factory RidePaymentModel.fromRows({
    required Map<String, dynamic> paymentRow,
    required Map<String, dynamic> reservationRow,
    required Map<String, dynamic> rideRow,
    required String driverName,
    required String riderName,
    required List<PaymentMethod> availableMethods,
  }) {
    return RidePaymentModel(
      id: _toInt(paymentRow['id']),
      reservationId: paymentRow['reservation_id'].toString(),
      rideId: reservationRow['ride_id'].toString(),
      driverId: _toInt(paymentRow['driver_id']),
      riderId: _toInt(paymentRow['rider_id']),
      amount: _toInt(paymentRow['amount']),
      deadline: _toDateTime(paymentRow['deadline']),
      state: paymentRow['state']?.toString() ?? 'PENDIENTE',
      type: paymentRow['type']?.toString(),
      driverName: driverName,
      riderName: riderName,
      source: rideRow['source']?.toString() ?? '',
      destination: rideRow['destination']?.toString() ?? '',
      date: rideRow['date']?.toString() ?? '',
      departureTime: rideRow['departure_time']?.toString() ?? '',
      availableMethods: availableMethods,
    );
  }

  factory RidePaymentModel.fromRpc({
    required Map<String, dynamic> paymentRow,
    required Map<String, dynamic> rideRow,
    required int driverId,
    required int riderId,
    required String driverName,
    required String riderName,
    required List<PaymentMethod> availableMethods,
  }) {
    return RidePaymentModel(
      id: _toInt(paymentRow['id']),
      reservationId: paymentRow['reservation_id']?.toString() ?? '',
      rideId: rideRow['id'].toString(),
      driverId: driverId,
      riderId: riderId,
      amount: _toInt(paymentRow['amount']),
      deadline: _toDateTime(paymentRow['deadline']),
      state: paymentRow['state']?.toString() ?? 'PENDIENTE',
      type: paymentRow['type']?.toString(),
      driverName: driverName,
      riderName: riderName,
      source: rideRow['source']?.toString() ?? '',
      destination: rideRow['destination']?.toString() ?? '',
      date: rideRow['date']?.toString() ?? '',
      departureTime: rideRow['departure_time']?.toString() ?? '',
      availableMethods: availableMethods,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
