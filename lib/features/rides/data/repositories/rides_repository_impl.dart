import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/zone.dart';
import '../../domain/entities/ride.dart';
import '../../domain/repositories/rides_repository.dart';
import '../datasources/rides_remote_datasource.dart';
import '../models/ride_model.dart';

class RidesRepositoryImpl implements RidesRepository {
  final RidesRemoteDatasource _datasource;

  RidesRepositoryImpl({
    required DioClient    client,
    required TokenStorage tokenStorage,
  }) : _datasource = RidesRemoteDatasource(
          client:       client,
          tokenStorage: tokenStorage,
        );

  @override
  Future<List<Vehicle>> getVehiclesByDriver(int driverId) =>
      _datasource.getVehiclesByDriver(driverId);

  @override
  Future<Ride> createRide(Ride ride) {
    final model = RideModel(
      driverId:      ride.driverId,
      vehicleId:     ride.vehicleId,
      zoneId:        ride.zoneId,
      source:        ride.source,
      destination:   ride.destination,
      date:          ride.date,
      departureTime: ride.departureTime,
      state:         'OFERTADO',
      type:          ride.type,
      price:         ride.price,
    );
    return _datasource.createRide(model);
  }

  Future<int> getDriverIdByUserId(int userId) =>
      _datasource.getDriverIdByUserId(userId);

  Future<int> getUserIdFromToken() =>
      _datasource.getUserIdFromToken();

  Future<List<Zone>> getZones() =>
      _datasource.getZones();
}