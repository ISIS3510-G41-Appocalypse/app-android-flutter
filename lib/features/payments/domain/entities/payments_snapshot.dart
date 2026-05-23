import 'ride_payment.dart';

class PaymentsSnapshot {
  final List<RidePayment> payments;
  final bool isFromCache;

  const PaymentsSnapshot({required this.payments, required this.isFromCache});
}
