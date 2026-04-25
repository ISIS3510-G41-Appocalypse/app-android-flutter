import '../../../domain/entities/driver_ride.dart';

class DriverRideViewData {
  final String title;
  final String source;
  final String destination;
  final String state;
  final String stateLabel;
  final String departureTimeLabel;
  final String availableSlotsLabel;
  final bool canStart;
  final bool showStartedBanner;
  final String? startAvailableFromLabel;

  const DriverRideViewData({
    required this.title,
    required this.source,
    required this.destination,
    required this.state,
    required this.stateLabel,
    required this.departureTimeLabel,
    required this.availableSlotsLabel,
    required this.canStart,
    required this.showStartedBanner,
    required this.startAvailableFromLabel,
  });

  factory DriverRideViewData.fromEntity(DriverRide ride, {DateTime? now}) {
    final referenceTime = now ?? DateTime.now();
    final startAllowedAt = _startAllowedAt(ride);
    final canStart =
        ride.state == 'OFERTADO' &&
        startAllowedAt != null &&
        !referenceTime.isBefore(startAllowedAt);

    return DriverRideViewData(
      title: 'Mi viaje como conductor',
      source: ride.source,
      destination: ride.destination,
      state: ride.state,
      stateLabel: _formatState(ride.state),
      departureTimeLabel: 'Salida: ${_formatTime(ride.departureTime)}',
      availableSlotsLabel: ride.availableSlots == 1
          ? '1 cupo disponible'
          : '${ride.availableSlots} cupos disponibles',
      canStart: canStart,
      showStartedBanner: ride.state == 'EN_CURSO',
      startAvailableFromLabel: ride.state == 'OFERTADO' && !canStart
          ? _buildStartAvailableFromLabel(startAllowedAt)
          : null,
    );
  }

  static DateTime? _startAllowedAt(DriverRide ride) {
    final dateParts = ride.date.split('-');
    if (dateParts.length != 3) {
      return null;
    }

    final timeParts = ride.departureTime.split(':');
    if (timeParts.length < 2) {
      return null;
    }

    final year = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final day = int.tryParse(dateParts[2]);
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    final second = timeParts.length > 2 ? int.tryParse(timeParts[2]) ?? 0 : 0;

    if (year == null ||
        month == null ||
        day == null ||
        hour == null ||
        minute == null) {
      return null;
    }

    return DateTime(
      year,
      month,
      day,
      hour,
      minute,
      second,
    ).subtract(const Duration(minutes: 5));
  }

  static String? _buildStartAvailableFromLabel(DateTime? startAllowedAt) {
    if (startAllowedAt == null) {
      return 'No pudimos validar desde que hora puedes iniciar este viaje.';
    }

    return 'Podras iniciar este viaje desde las ${_formatDateTime(startAllowedAt)}.';
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

  static String _formatDateTime(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
