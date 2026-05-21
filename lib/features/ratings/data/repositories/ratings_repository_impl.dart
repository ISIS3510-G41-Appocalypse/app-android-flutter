import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_checker.dart';
import '../../domain/entities/rate_driver.dart';
import '../../domain/entities/rate_rider.dart';
import '../../domain/repositories/ratings_repository.dart';
import '../data_sources/ratings_remote_data_source.dart';
import '../models/rate_driver_model.dart';
import '../models/rate_rider_model.dart';

class RatingsRepositoryImpl implements RatingsRepository {
  final RatingsRemoteDataSource remoteDataSource;
  final NetworkChecker networkChecker;

  RatingsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkChecker,
  });

  @override
  Future<Either<Failure, void>> submitDriverRating(RateDriver rating) async {
    final validationMessage = _validateDriverRating(rating);
    if (validationMessage != null) {
      return Left(ServerFailure(validationMessage));
    }

    if (!await networkChecker.hasInternet) {
      return const Left(
        NetworkFailure(
          'No tienes internet. Esta accion requiere conexion para completarse.',
        ),
      );
    }

    try {
      await remoteDataSource.submitDriverRating(
        RateDriverModel.fromEntity(rating),
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('Error inesperado al calificar al conductor'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> submitRiderRatings(
    List<RateRider> ratings,
  ) async {
    if (ratings.isEmpty) {
      return const Left(ServerFailure('No hay pasajeros para calificar.'));
    }

    for (final rating in ratings) {
      final validationMessage = _validateRiderRating(rating);
      if (validationMessage != null) {
        return Left(ServerFailure(validationMessage));
      }
    }

    if (!await networkChecker.hasInternet) {
      return const Left(
        NetworkFailure(
          'No tienes internet. Esta accion requiere conexion para completarse.',
        ),
      );
    }

    try {
      await remoteDataSource.submitRiderRatings(
        ratings.map(RateRiderModel.fromEntity).toList(),
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('Error inesperado al calificar pasajeros'),
      );
    }
  }

  String? _validateDriverRating(RateDriver rating) {
    if (rating.riderId <= 0 || rating.driverId <= 0 || rating.rideId.isEmpty) {
      return 'No pudimos identificar el viaje o los perfiles a calificar.';
    }

    if (!_isScoreValid(rating.punctuality) ||
        !_isScoreValid(rating.behavior) ||
        !_isScoreValid(rating.communication) ||
        !_isScoreValid(rating.security)) {
      return 'Completa todos los puntajes antes de enviar.';
    }

    return null;
  }

  String? _validateRiderRating(RateRider rating) {
    if (rating.riderId <= 0 || rating.driverId <= 0 || rating.rideId.isEmpty) {
      return 'No pudimos identificar el viaje o los perfiles a calificar.';
    }

    if (!_isScoreValid(rating.punctuality) ||
        !_isScoreValid(rating.behavior) ||
        !_isScoreValid(rating.communication) ||
        !_isScoreValid(rating.paymentPunctuality)) {
      return 'Completa todos los puntajes antes de enviar.';
    }

    return null;
  }

  bool _isScoreValid(int value) {
    return value >= 1 && value <= 5;
  }
}
