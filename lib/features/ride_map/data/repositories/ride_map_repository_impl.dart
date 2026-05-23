import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/location/device_location_service.dart';
import '../../../../core/network/network_checker.dart';
import '../../domain/entities/ride_map_location.dart';
import '../../domain/repositories/ride_map_repository.dart';
import '../data_sources/ride_map_remote_data_source.dart';
import '../local/ride_map_location_cache.dart';
import '../models/ride_map_location_model.dart';

class RideMapRepositoryImpl implements RideMapRepository {
  final RideMapRemoteDataSource remoteDataSource;
  final RideMapLocationCache cache;
  final NetworkChecker networkChecker;
  final DeviceLocationService locationService;

  RideMapRepositoryImpl({
    required this.remoteDataSource,
    required this.cache,
    required this.networkChecker,
    required this.locationService,
  });

  @override
  Future<Either<Failure, List<RideMapLocation>>> getRideLocations({
    required String rideId,
    required Map<int, String> passengerNamesByUserId,
    double? originLatitude,
    double? originLongitude,
  }) async {
    if (!await networkChecker.hasInternet) {
      final cached = _withDistances(
        cache
            .getLocations(rideId: rideId)
            .map((model) => model.toEntity())
            .where((location) => location.hasValidCoordinates)
            .toList(),
        originLatitude,
        originLongitude,
      );

      if (cached.isNotEmpty) {
        return Right(cached);
      }

      return const Left(
        NetworkFailure(
          'No tienes internet. Ultimas posiciones no disponibles.',
        ),
      );
    }

    try {
      final rows = await remoteDataSource.getRideLocationRows(
        rideId: rideId,
        userIds: passengerNamesByUserId.keys.toList(),
      );
      final latestByUserId = <int, RideMapLocationModel>{};
      for (final row in rows) {
        final model = RideMapLocationModel.fromJson(row);
        latestByUserId.putIfAbsent(model.userId, () => model);
      }

      final models = latestByUserId.values.map((model) {
        return RideMapLocationModel(
          id: model.id,
          rideId: model.rideId,
          userId: model.userId,
          participantName: passengerNamesByUserId[model.userId] ?? 'Pasajero',
          latitude: model.latitude,
          longitude: model.longitude,
          updatedAt: model.updatedAt,
        );
      }).toList();
      final locations = models
          .map((model) => model.toEntity())
          .where((location) => location.hasValidCoordinates)
          .toList();

      if (locations.isNotEmpty) {
        await cache.saveLocations(rideId: rideId, locations: models);
      }

      return Right(_withDistances(locations, originLatitude, originLongitude));
    } on ServerException catch (e) {
      final cached = _withDistances(
        cache
            .getLocations(rideId: rideId)
            .map((model) => model.toEntity())
            .where((location) => location.hasValidCoordinates)
            .toList(),
        originLatitude,
        originLongitude,
      );

      if (cached.isNotEmpty) {
        return Right(cached);
      }

      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('Error inesperado al obtener ubicaciones del viaje'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> publishUserLocation({
    required String rideId,
    required int userId,
    required double latitude,
    required double longitude,
  }) async {
    if (!await networkChecker.hasInternet) {
      return const Left(
        NetworkFailure('No tienes internet. Mostraremos posiciones guardadas.'),
      );
    }

    try {
      await remoteDataSource.createUserLocation(
        rideId: rideId,
        userId: userId,
        latitude: latitude,
        longitude: longitude,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('Error inesperado al publicar tu ubicacion'),
      );
    }
  }

  List<RideMapLocation> _withDistances(
    List<RideMapLocation> locations,
    double? originLatitude,
    double? originLongitude,
  ) {
    if (originLatitude == null || originLongitude == null) {
      return locations;
    }

    return locations.map((location) {
      final distance = locationService.distanceBetween(
        startLatitude: originLatitude,
        startLongitude: originLongitude,
        endLatitude: location.latitude,
        endLongitude: location.longitude,
      );
      return location.copyWithDistance(distance);
    }).toList();
  }
}
