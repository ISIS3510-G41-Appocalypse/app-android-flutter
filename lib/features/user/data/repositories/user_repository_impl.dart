import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/auth.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/user_datasource_remote.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSourceRemote dataSourceRemote;

  UserRepositoryImpl({
    required this.dataSourceRemote,
  });

  @override
  Future<Either<Failure, User>> loadUser({
    required Auth auth,
  }) async {
    try {
      final user = await dataSourceRemote.loadUser(auth: auth);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Error inesperado al cargar el usuario'));
    }
  }
}
