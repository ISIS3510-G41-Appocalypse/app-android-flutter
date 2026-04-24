import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_datasource_remote.dart';

class UserRepositoryRemote implements UserRepository {
  final UserDataSourceRemote dataSourceRemote;

  UserRepositoryRemote({
    required this.dataSourceRemote,
  });

  @override
  Future<Either<Failure, UserProfile>> getRiderProfile({
    required int riderId,
  }) async {
    try {
      final profile = await dataSourceRemote.getRiderProfile(riderId: riderId);
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Error inesperado al cargar el rider'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> getDriverProfile({
    required int driverId,
  }) async {
    try {
      final profile = await dataSourceRemote.getDriverProfile(driverId: driverId);
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Error inesperado al cargar el driver'));
    }
  }
}
