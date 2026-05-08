import '../../models/ride_recommendation_model.dart';

abstract class RideRecommendationRemoteDataSource {
  Future<RideRecommendationModel?> getRecommendation({
    required int riderId,
    required int driverId,
  });
}
