import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ride_recommendation.dart';

abstract class RideRecommendationRepository {
  Future<Either<Failure, RideRecommendation?>> getRecommendation({
    required int riderId,
    required int driverId,
  });
}
