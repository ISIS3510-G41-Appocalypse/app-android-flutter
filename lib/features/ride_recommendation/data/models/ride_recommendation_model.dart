import '../../../../core/helpers/json_parsers.dart';
import '../../domain/entities/ride_recommendation.dart';

class RideRecommendationModel extends RideRecommendation {
  const RideRecommendationModel({
    required super.riderId,
    required super.driverId,
    required super.rating,
  });

  factory RideRecommendationModel.fromJson(Map<String, dynamic> json) {
    return RideRecommendationModel(
      riderId: JsonParsers.parseInt(json['rider_id']),
      driverId: JsonParsers.parseInt(json['driver_id']),
      rating: JsonParsers.parseDouble(json['rating']).clamp(0, 5).toDouble(),
    );
  }
}
