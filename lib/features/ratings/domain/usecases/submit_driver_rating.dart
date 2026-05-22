import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/rate_driver.dart';
import '../repositories/ratings_repository.dart';

class SubmitDriverRating {
  final RatingsRepository repository;

  SubmitDriverRating(this.repository);

  Future<Either<Failure, void>> call(RateDriver rating) {
    return repository.submitDriverRating(rating);
  }
}
