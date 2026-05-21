import '../../../domain/entities/rating_passenger.dart';

enum RatingsMode { driverRatesRiders, riderRatesDriver }

class RatingsPageArgs {
  final RatingsMode mode;
  final String rideId;
  final int driverId;
  final int? riderId;
  final String? driverName;
  final List<RatingPassenger> passengers;

  const RatingsPageArgs.driverRatesRiders({
    required this.rideId,
    required this.driverId,
    required this.passengers,
  }) : mode = RatingsMode.driverRatesRiders,
       riderId = null,
       driverName = null;

  const RatingsPageArgs.riderRatesDriver({
    required this.rideId,
    required this.driverId,
    required int this.riderId,
    required String this.driverName,
  }) : mode = RatingsMode.riderRatesDriver,
       passengers = const [];
}
