import '../../../domain/entities/driver_ride.dart';

class DriverRideViewData {
  final String title;
  final String source;
  final String destination;
  final String stateLabel;
  final String departureTimeLabel;
  final String availableSlotsLabel;

  const DriverRideViewData({
    required this.title,
    required this.source,
    required this.destination,
    required this.stateLabel,
    required this.departureTimeLabel,
    required this.availableSlotsLabel,
  });

  factory DriverRideViewData.fromEntity(DriverRide ride) {
    return DriverRideViewData(
      title: 'Mi viaje como conductor',
      source: ride.source,
      destination: ride.destination,
      stateLabel: _formatState(ride.state),
      departureTimeLabel: 'Salida: ${_formatTime(ride.departureTime)}',
      availableSlotsLabel: ride.availableSlots == 1
          ? '1 cupo disponible'
          : '${ride.availableSlots} cupos disponibles',
    );
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

  static String _formatState(String value) {
    switch (value) {
      case 'OFERTADO':
        return 'Ofertado';
      case 'EN_CURSO':
        return 'En curso';
      case 'FINALIZADO':
        return 'Finalizado';
      case 'CANCELADO':
        return 'Cancelado';
      default:
        return value;
    }
  }
}
