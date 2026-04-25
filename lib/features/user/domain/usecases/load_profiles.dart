import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class LoadProfiles {
  final UserRepository repository;

  LoadProfiles(this.repository);

  Future<Either<Failure, User>> call({
    required User currentUser,
  }) {
    return repository.loadProfiles(currentUser: currentUser);
  }
}
