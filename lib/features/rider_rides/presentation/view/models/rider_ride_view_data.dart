import '../../../domain/entities/rider_ride.dart';

class RiderRideViewData {
  final String title;
  final String driverName;
  final String state;
  final String stateLabel;
  final String departureTimeLabel;
  final String dateLabel;
  final String meetingPoint;
  final String destinationPoint;
  final String priceText;
  final String carModel;
  final bool canCancel;

  const RiderRideViewData({
    required this.title,
    required this.driverName,
    required this.state,
    required this.stateLabel,
    required this.departureTimeLabel,
    required this.dateLabel,
    required this.meetingPoint,
    required this.destinationPoint,
    required this.priceText,
    required this.carModel,
    required this.canCancel,
  });

  factory RiderRideViewData.fromEntity(RiderRide ride) {
    return RiderRideViewData(
      title: 'Mi reserva como pasajero',
      driverName: ride.driverName,
      state: ride.state,
      stateLabel: _formatState(ride.state),
      departureTimeLabel: 'Salida: ${_formatTime(ride.departureTime)}',
      dateLabel: _formatDate(ride.date),
      meetingPoint: ride.meetingPoint.isNotEmpty
          ? ride.meetingPoint
          : ride.source,
      destinationPoint: ride.destinationPoint.isNotEmpty
          ? ride.destinationPoint
          : ride.destination,
      priceText: _formatCurrency(ride.price),
      carModel: ride.carModel,
      canCancel: ride.state == 'PENDIENTE' || ride.state == 'ACEPTADA',
    );
  }

  static String _formatState(String value) {
    switch (value) {
      case 'PENDIENTE':
        return 'En espera';
      case 'ACEPTADA':
        return 'Aceptada';
      case 'EN_CURSO':
        return 'En curso';
      case 'FINALIZADA':
        return 'Finalizada';
      case 'RECHAZADA':
        return 'Rechazado';
      case 'CANCELADA':
        return 'Cancelada';
      default:
        return value;
    }
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

  static String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
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
}
