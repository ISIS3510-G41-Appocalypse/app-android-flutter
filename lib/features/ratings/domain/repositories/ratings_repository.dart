import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/rate_driver.dart';
import '../entities/rate_rider.dart';

abstract class RatingsRepository {
  Future<Either<Failure, void>> submitDriverRating(RateDriver rating);

  Future<Either<Failure, void>> submitRiderRatings(List<RateRider> ratings);
}
