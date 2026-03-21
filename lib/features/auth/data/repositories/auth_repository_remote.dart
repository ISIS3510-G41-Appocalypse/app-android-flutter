import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource_remote.dart';

class AuthRepositoryRemote implements AuthRepository {
  final AuthDataSourceRemote dataSourceRemote;
  final TokenStorage tokenStorage;

  AuthRepositoryRemote({
    required this.dataSourceRemote,
    required this.tokenStorage,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await dataSourceRemote.login(
        email: email,
        password: password,
      );
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
      await tokenStorage.clearSession();
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Error al cerrar sesión'));
    }
  }

  @override
  Future<Either<Failure, User>> restoreSession() async {
    try {
      final session = await tokenStorage.hasSession();
      if (!session) {
        return const Left(ServerFailure('No hay token guardado'));
      }
      final user = await dataSourceRemote.restoreSession();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Error al restaurar sesión'));
    }
  }
}