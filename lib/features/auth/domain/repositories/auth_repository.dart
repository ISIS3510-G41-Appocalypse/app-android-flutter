import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth.dart';

abstract class AuthRepository {
  Future<Either<Failure, Auth>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, Auth>> restoreSession();
}
