import '../../domain/entities/payment_method.dart';
import '../../domain/entities/ride_payment.dart';
import 'payment_method_model.dart';

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

  factory RidePaymentModel.fromEntity(RidePayment payment) {
    return RidePaymentModel(
      id: payment.id,
      reservationId: payment.reservationId,
      rideId: payment.rideId,
      driverId: payment.driverId,
      riderId: payment.riderId,
      amount: payment.amount,
      deadline: payment.deadline,
      state: payment.state,
      type: payment.type,
      driverName: payment.driverName,
      riderName: payment.riderName,
      source: payment.source,
      destination: payment.destination,
      date: payment.date,
      departureTime: payment.departureTime,
      availableMethods: payment.availableMethods,
    );
  }

  factory RidePaymentModel.fromJson(Map<String, dynamic> json) {
    final rawMethods = json['available_methods'];
    final methods = rawMethods is List
        ? rawMethods.whereType<Map>().map((method) {
            return PaymentMethodModel.fromJson(
              Map<String, dynamic>.from(method),
            );
          }).toList()
        : <PaymentMethod>[];

    return RidePaymentModel(
      id: _toInt(json['id']),
      reservationId: json['reservation_id']?.toString() ?? '',
      rideId: json['ride_id']?.toString() ?? '',
      driverId: _toInt(json['driver_id']),
      riderId: _toInt(json['rider_id']),
      amount: _toInt(json['amount']),
      deadline: _toDateTime(json['deadline']),
      state: json['state']?.toString() ?? 'PENDIENTE',
      type: json['type']?.toString(),
      driverName: json['driver_name']?.toString() ?? '',
      riderName: json['rider_name']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      departureTime: json['departure_time']?.toString() ?? '',
      availableMethods: methods,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservation_id': reservationId,
      'ride_id': rideId,
      'driver_id': driverId,
      'rider_id': riderId,
      'amount': amount,
      'deadline': deadline?.toIso8601String(),
      'state': state,
      'type': type,
      'driver_name': driverName,
      'rider_name': riderName,
      'source': source,
      'destination': destination,
      'date': date,
      'departure_time': departureTime,
      'available_methods': availableMethods
          .map((method) => PaymentMethodModel.fromEntity(method).toJson())
          .toList(),
    };
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
