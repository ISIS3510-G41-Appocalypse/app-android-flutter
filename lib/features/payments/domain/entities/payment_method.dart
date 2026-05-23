class PaymentMethod {
  final int id;
  final int driverId;
  final String type;
  final String? numberAccount;

  const PaymentMethod({
    required this.id,
    required this.driverId,
    required this.type,
    this.numberAccount,
  });

  String get displayName {
    final account = numberAccount?.trim();
    if (account == null || account.isEmpty) {
      return type;
    }

    return '$type - $account';
  }
}
