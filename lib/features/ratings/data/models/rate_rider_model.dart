import '../../domain/entities/rate_rider.dart';

class RateRiderModel extends RateRider {
  const RateRiderModel({
    required super.riderId,
    required super.driverId,
    required super.punctuality,
    required super.behavior,
    required super.communication,
    required super.paymentPunctuality,
    required super.rideId,
  });

  factory RateRiderModel.fromEntity(RateRider rating) {
    return RateRiderModel(
      riderId: rating.riderId,
      driverId: rating.driverId,
      punctuality: rating.punctuality,
      behavior: rating.behavior,
      communication: rating.communication,
      paymentPunctuality: rating.paymentPunctuality,
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
      'payment_punctuality': paymentPunctuality,
      'ride_id': int.tryParse(rideId) ?? rideId,
    };
  }
}
