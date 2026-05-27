import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_checker.dart';
import '../../../auth/domain/entities/auth.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/user_datasource_local.dart';
import '../models/user_model.dart';
import '../datasources/remote/user_datasource_remote.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSourceRemote dataSourceRemote;
  final NetworkChecker networkChecker;
  final UserDataSourceLocal dataSourceLocal;

  UserRepositoryImpl({
    required this.dataSourceRemote,
    required this.networkChecker,
    required this.dataSourceLocal,
  });

  @override
  User? getCachedUser({
    required Auth auth,
  }) {
    return dataSourceLocal.getUser(authId: auth.authId);
  }

  @override
  Future<Either<Failure, User>> loadUser({
    required Auth auth,
  }) async {
    try {
      final user = await dataSourceRemote.loadUser(auth: auth);
      await dataSourceLocal.saveUser(user: UserModel.fromEntity(user));
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Error inesperado al cargar el usuario'));
    }
  }

  @override
  Future<Either<Failure, User>> loadProfiles({
    required User currentUser,
  }) async {
    try {
      if (!await networkChecker.hasInternet) {
        return const Left(
          NetworkFailure('No tienes internet. Intenta de nuevo mas tarde.'),
        );
      }

      final profiles = await dataSourceRemote.loadProfiles(
        userId: currentUser.id,
      );

      final updatedUser = User(
        id: currentUser.id,
        firstName: currentUser.firstName,
        lastName: currentUser.lastName,
        zoneId: currentUser.zoneId,
        authId: currentUser.authId,
        email: currentUser.email,
        rider: profiles.rider,
        driver: profiles.driver,
      );

      await dataSourceLocal.saveUser(user: UserModel.fromEntity(updatedUser));
      return Right(updatedUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Error al cargar los perfiles'));
    }
  }
}
