import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ride_recommendation.dart';
import '../repositories/ride_recommendation_repository.dart';

class GetRideRecommendation {
  final RideRecommendationRepository repository;

  GetRideRecommendation(this.repository);

  Future<Either<Failure, RideRecommendation?>> call({
    required int riderId,
    required int driverId,
  }) {
    return repository.getRecommendation(
      riderId: riderId,
      driverId: driverId,
    );
  }
}
