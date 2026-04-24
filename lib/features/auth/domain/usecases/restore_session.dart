import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth.dart';
import '../repositories/auth_repository.dart';

class RestoreSession {
  final AuthRepository repository;

  RestoreSession(this.repository);

  Future<Either<Failure, Auth>> call() async {
    return await repository.restoreSession();
  }
}
