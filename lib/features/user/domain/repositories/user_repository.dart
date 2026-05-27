import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/auth.dart';
import '../entities/user.dart';

abstract class UserRepository {
  User? getCachedUser({
    required Auth auth,
  });

  Future<Either<Failure, User>> loadUser({
    required Auth auth,
  });

  Future<Either<Failure, User>> loadProfiles({
    required User currentUser,
  });
}
