import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/driver_ride.dart';
import '../../domain/repositories/driver_rides_repository.dart';
import '../data_sources/driver_rides_remote_data_source.dart';
import '../models/driver_ride_model.dart';

class DriverRidesRepositoryImpl implements DriverRidesRepository {
  final DriverRidesRemoteDataSource remoteDataSource;

  DriverRidesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DriverRide?>> getActiveDriverRide({
    required int? driverId,
  }) async {
    if (driverId == null) {
      return const Right(null);
    }

    try {
      final rideRow = await remoteDataSource.getActiveDriverRideRow(
        driverId: driverId,
      );

      if (rideRow == null) {
        return const Right(null);
      }

      final vehicleId = _toInt(rideRow['vehicle_id']);
      final vehicleRow = await remoteDataSource.getVehicleRow(
        vehicleId: vehicleId,
      );
      final availableSlots = (_toInt(vehicleRow['number_slots']) - 1).clamp(
        0,
        99,
      );

      final ride = DriverRideModel.fromJson(
        rideRow,
        availableSlots: availableSlots,
      ).toEntity();

      return Right(ride);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('Error inesperado al obtener el viaje del conductor'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateRideState({
    required String rideId,
    required String state,
  }) async {
    try {
      await remoteDataSource.updateRideState(rideId: rideId, state: state);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('Error inesperado al actualizar el estado del viaje'),
      );
    }
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }
}
