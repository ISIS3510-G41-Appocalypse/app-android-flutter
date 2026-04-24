import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth.dart';
import '../repositories/auth_repository.dart';

class VerifySession {
  final AuthRepository repository;

  VerifySession(this.repository);

  Future<Either<Failure, Auth>> call() async {
    return await repository.verifySession();
  }
}
