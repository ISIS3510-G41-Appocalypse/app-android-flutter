import '../../../domain/entities/ride_offer.dart';

class RideOfferViewData {
  final String id;
  final String driverName;
  final String ratingText;
  final String tripsText;
  final String priceText;
  final String source;
  final String destination;
  final String departureTimeLabel;
  final String slotsText;
  final String carModel;
  final String zoneName;
  final String typeLabel;

  const RideOfferViewData({
    required this.id,
    required this.driverName,
    required this.ratingText,
    required this.tripsText,
    required this.priceText,
    required this.source,
    required this.destination,
    required this.departureTimeLabel,
    required this.slotsText,
    required this.carModel,
    required this.zoneName,
    required this.typeLabel,
  });

  factory RideOfferViewData.fromEntity(RideOffer offer) {
    return RideOfferViewData(
      id: offer.id,
      driverName: offer.driverName,
      ratingText: offer.driverRating.toStringAsFixed(1),
      tripsText: offer.tripsCount == 1
          ? '1 viaje'
          : '${offer.tripsCount} viajes',
      priceText: _formatCurrency(offer.price),
      source: offer.source,
      destination: offer.destination,
      departureTimeLabel: 'Salida: ${_formatTime(offer.departureTime)}',
      slotsText: offer.slots == 1 ? '1 cupo' : '${offer.slots} cupos',
      carModel: offer.carModel,
      zoneName: offer.zoneName,
      typeLabel: _formatType(offer.type),
    );
  }

  static String _formatCurrency(int value) {
    final digits = value.toString().split('').reversed.toList();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }

    return '\$${buffer.toString().split('').reversed.join()}';
  }

  static String _formatTime(String value) {
    final parts = value.split(':');
    final parsedHour = int.tryParse(parts.first) ?? 0;
    final parsedMinute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final hour = parsedHour % 12 == 0 ? 12 : parsedHour % 12;
    final minute = parsedMinute.toString().padLeft(2, '0');
    final period = parsedHour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  static String _formatType(String value) {
    switch (value) {
      case 'TO_UNIVERSITY':
        return 'Llegada a la universidad';
      case 'FROM_UNIVERSITY':
        return 'Salida de la universidad';
      default:
        return value;
    }
  }
}
