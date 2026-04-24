import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_model.dart';
import '../datasources/local/auth_datasource_local.dart';
import '../datasources/remote/auth_datasource_remote.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSourceRemote dataSourceRemote;
  final AuthDataSourceLocal dataSourceLocal;

  AuthRepositoryImpl({
    required this.dataSourceRemote,
    required this.dataSourceLocal,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final auth = await dataSourceRemote.login(
        email: email,
        password: password,
      );

      await dataSourceLocal.saveSession(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );

      final user = await dataSourceRemote.getUser(auth: auth);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Error inesperado en login'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await dataSourceLocal.clearSession();
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Error al cerrar sesion'));
    }
  }

  @override
  Future<Either<Failure, User>> restoreSession() async {
    try {
      final hasSession = await dataSourceLocal.hasSession();
      if (!hasSession) {
        return const Left(ServerFailure('No hay token guardado'));
      }

      AuthModel auth;
      try {
        auth = await dataSourceRemote.verifySession();
      } on ServerException catch (e) {
        if (e.message != 'La sesion expiro') {
          rethrow;
        }

        final session = await dataSourceLocal.getSession();
        if (session == null) {
          return const Left(ServerFailure('No hay sesion disponible'));
        }

        auth = await dataSourceRemote.refreshSession(
          refreshToken: session.refreshToken,
        );

        await dataSourceLocal.saveSession(
          accessToken: auth.accessToken,
          refreshToken: auth.refreshToken,
        );
      }

      final user = await dataSourceRemote.getUser(auth: auth);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Error al restaurar sesion'));
    }
  }
}
