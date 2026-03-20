import '../entities/vehicle.dart';
import '../entities/ride.dart';

abstract class RidesRepository {
  Future<List<Vehicle>> getVehiclesByDriver(int driverId);
  Future<Ride> createRide(Ride ride);
}