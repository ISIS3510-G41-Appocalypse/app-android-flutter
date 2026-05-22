import '../../domain/entities/rate_driver.dart';

class RateDriverModel extends RateDriver {
  const RateDriverModel({
    required super.riderId,
    required super.driverId,
    required super.punctuality,
    required super.behavior,
    required super.communication,
    required super.security,
    required super.rideId,
  });

  factory RateDriverModel.fromEntity(RateDriver rating) {
    return RateDriverModel(
      riderId: rating.riderId,
      driverId: rating.driverId,
      punctuality: rating.punctuality,
      behavior: rating.behavior,
      communication: rating.communication,
      security: rating.security,
      rideId: rating.rideId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rider_id': riderId,
      'driver_id': driverId,
      'punctuality': punctuality,
      'behavior': behavior,
      'communication': communication,
      'security': security,
      'ride_id': int.tryParse(rideId) ?? rideId,
    };
  }
}
