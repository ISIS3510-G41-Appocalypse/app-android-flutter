import '../models/rate_driver_model.dart';
import '../models/rate_rider_model.dart';

abstract class RatingsRemoteDataSource {
  Future<void> submitDriverRating(RateDriverModel rating);

  Future<void> submitRiderRatings(List<RateRiderModel> ratings);
}
