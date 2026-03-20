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
  final String availableSeatsText;
  final String carModel;
  final String zoneName;
  final String tripType;

  const RideOfferViewData({
    required this.id,
    required this.driverName,
    required this.ratingText,
    required this.tripsText,
    required this.priceText,
    required this.source,
    required this.destination,
    required this.departureTimeLabel,
    required this.availableSeatsText,
    required this.carModel,
    required this.zoneName,
    required this.tripType,
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
      departureTimeLabel:
          'Hora de salida: ${_formatTime(offer.departureDateTime)}',
      availableSeatsText: offer.availableSeats == 1
          ? '1 disponible'
          : '${offer.availableSeats} disponibles',
      carModel: offer.carModel,
      zoneName: offer.zoneName,
      tripType: offer.tripType,
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

  static String _formatTime(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
