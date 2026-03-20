import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await remoteDataSource.login(
        email: email,
        password: password,
      );

      final user = await remoteDataSource.getUserByAuthId(
        authResponse: authResponse,
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
}