import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/auth.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class LoadUser {
  final UserRepository repository;

  LoadUser(this.repository);

  Future<Either<Failure, User>> call({
    required Auth auth,
  }) {
    return repository.loadUser(auth: auth);
  }
}
