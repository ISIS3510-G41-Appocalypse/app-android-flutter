import 'package:hive_flutter/hive_flutter.dart';

import '../models/ride_payment_model.dart';

class PaymentsCacheStorage {
  static const String _boxName = 'payments_cache';
  static const String _driverPrefix = 'driver';
  static const String _riderPrefix = 'rider';

  late Box<Map> _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  Future<void> saveDriverPayments({
    required int driverId,
    required List<RidePaymentModel> payments,
  }) {
    return _savePayments(_key(_driverPrefix, driverId), payments);
  }

  Future<void> saveRiderPayments({
    required int riderId,
    required List<RidePaymentModel> payments,
  }) {
    return _savePayments(_key(_riderPrefix, riderId), payments);
  }

  List<RidePaymentModel> getDriverPayments({required int driverId}) {
    return _getPayments(_key(_driverPrefix, driverId));
  }

  List<RidePaymentModel> getRiderPayments({required int riderId}) {
    return _getPayments(_key(_riderPrefix, riderId));
  }

  Future<void> _savePayments(
    String key,
    List<RidePaymentModel> payments,
  ) async {
    await _box.put(key, {
      'updated_at': DateTime.now().toIso8601String(),
      'payments': payments.map((payment) => payment.toJson()).toList(),
    });
  }

  List<RidePaymentModel> _getPayments(String key) {
    final data = _box.get(key);
    if (data == null) {
      return const [];
    }

    final map = Map<String, dynamic>.from(data);
    final rawPayments = map['payments'];
    if (rawPayments is! List) {
      return const [];
    }

    return rawPayments.whereType<Map>().map((payment) {
      return RidePaymentModel.fromJson(Map<String, dynamic>.from(payment));
    }).toList();
  }

  String _key(String prefix, int id) => '$prefix:$id';
}
