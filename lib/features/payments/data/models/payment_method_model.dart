import '../../domain/entities/payment_method.dart';

class PaymentMethodModel extends PaymentMethod {
  const PaymentMethodModel({
    required super.id,
    required super.driverId,
    required super.type,
    super.numberAccount,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: _toInt(json['id']),
      driverId: _toInt(json['driver_id']),
      type: json['type']?.toString() ?? '',
      numberAccount: json['number_account']?.toString(),
    );
  }

  factory PaymentMethodModel.fromEntity(PaymentMethod method) {
    return PaymentMethodModel(
      id: method.id,
      driverId: method.driverId,
      type: method.type,
      numberAccount: method.numberAccount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'type': type,
      'number_account': numberAccount,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
