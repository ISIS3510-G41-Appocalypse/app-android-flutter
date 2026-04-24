import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';
import '../repositories/user_repository.dart';

class GetDriverProfile {
  final UserRepository repository;

  GetDriverProfile(this.repository);

  Future<Either<Failure, UserProfile>> call({
    required int driverId,
  }) {
    return repository.getDriverProfile(driverId: driverId);
  }
}
