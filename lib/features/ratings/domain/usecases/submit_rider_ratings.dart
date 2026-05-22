import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/rate_rider.dart';
import '../repositories/ratings_repository.dart';

class SubmitRiderRatings {
  final RatingsRepository repository;

  SubmitRiderRatings(this.repository);

  Future<Either<Failure, void>> call(List<RateRider> ratings) {
    return repository.submitRiderRatings(ratings);
  }
}
