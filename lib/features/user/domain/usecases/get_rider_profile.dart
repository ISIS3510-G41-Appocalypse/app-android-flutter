import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';
import '../repositories/user_repository.dart';

class GetRiderProfile {
  final UserRepository repository;

  GetRiderProfile(this.repository);

  Future<Either<Failure, UserProfile>> call({
    required int riderId,
  }) {
    return repository.getRiderProfile(riderId: riderId);
  }
}
