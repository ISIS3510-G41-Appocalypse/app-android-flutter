import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';

abstract class UserRepository {
  Future<Either<Failure, UserProfile>> getRiderProfile({
    required int riderId,
  });

  Future<Either<Failure, UserProfile>> getDriverProfile({
    required int driverId,
  });
}
