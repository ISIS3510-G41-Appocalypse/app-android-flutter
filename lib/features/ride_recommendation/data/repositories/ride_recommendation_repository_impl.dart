import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_checker.dart';
import '../../domain/entities/ride_recommendation.dart';
import '../../domain/repositories/ride_recommendation_repository.dart';
import '../datasources/remote/ride_recommendation_remote_datasource.dart';

class RideRecommendationRepositoryImpl
    implements RideRecommendationRepository {
  final RideRecommendationRemoteDataSource remoteDataSource;
  final NetworkChecker networkChecker;

  RideRecommendationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkChecker,
  });

  @override
  Future<Either<Failure, RideRecommendation?>> getRecommendation({
    required int riderId,
    required int driverId,
  }) async {
    try {
      if (!await networkChecker.hasInternet) {
        return const Left(
          NetworkFailure(
            'No tienes internet. Revisa tu conexion e intenta de nuevo.',
          ),
        );
      }

      final recommendation = await remoteDataSource.getRecommendation(
        riderId: riderId,
        driverId: driverId,
      );

      return Right(recommendation);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('Error inesperado al consultar la recomendacion'),
      );
    }
  }
}
