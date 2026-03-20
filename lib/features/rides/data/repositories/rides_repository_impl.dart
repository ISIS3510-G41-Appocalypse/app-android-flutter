import '../../../../core/network/dio_client.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/zone.dart';
import '../../domain/entities/ride.dart';
import '../../domain/repositories/rides_repository.dart';
import '../datasources/rides_remote_datasource.dart';
import '../models/ride_model.dart';

class RidesRepositoryImpl implements RidesRepository {
  final RidesRemoteDatasource datasource;

  RidesRepositoryImpl({required DioClient client}): 
    datasource = RidesRemoteDatasource(client: client);

  @override
  Future<List<Vehicle>> getVehiclesByDriver(int driverId) =>
      datasource.getVehiclesByDriver(driverId);

  @override
  Future<Ride> createRide(Ride ride) {
    final model = RideModel(
      driverId: ride.driverId,
      vehicleId: ride.vehicleId,
      zoneId: ride.zoneId,
      source: ride.source,
      destination: ride.destination,
      date: ride.date,
      departureTime: ride.departureTime,
      state: 'OFERTADO',
      type: ride.type,
      price: ride.price,
    );
    return datasource.createRide(model);
  }

  Future<int> getDriverIdByUserId(int userId) =>
      datasource.getDriverIdByUserId(userId);

  Future<List<Zone>> getZones() =>
      datasource.getZones();
}