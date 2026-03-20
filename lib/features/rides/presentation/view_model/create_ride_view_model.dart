import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/repositories/rides_repository_impl.dart';
import '../../domain/entities/ride.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/zone.dart';
import 'create_ride_state.dart';

class CreateRideViewModel extends Cubit<CreateRideState> {
  final RidesRepositoryImpl _repository;

  CreateRideViewModel({
    required DioClient    client,
    required TokenStorage tokenStorage,
  }) : _repository = RidesRepositoryImpl(
          client:       client,
          tokenStorage: tokenStorage,
        ),
       super(CreateRideInitial());


  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName es requerido';
    return null;
  }

  String? validateVehicleSelected(Vehicle? vehicle) {
    if (vehicle == null) return 'Selecciona un vehículo';
    return null;
  }

  String? validateZoneSelected(Zone? zone) {
    if (zone == null) return 'Selecciona una zona';
    return null;
  }


  Future<void> loadVehicles() async {
    emit(CreateRideLoadingVehicles());
    try {
      final userId   = await _repository.getUserIdFromToken();
      final driverId = await _repository.getDriverIdByUserId(userId);

      // Carga vehículos y zonas en paralelo
      final results = await Future.wait([
        _repository.getVehiclesByDriver(driverId),
        _repository.getZones(),
      ]);

      final vehicles = results[0] as List<Vehicle>;
      final zones    = results[1] as List<Zone>;

      if (vehicles.isEmpty) {
        emit(CreateRideError('No tienes vehículos registrados.'));
        return;
      }

      emit(CreateRideReady(
        vehicles: vehicles,
        zones:    zones,
      ));
    } catch (e) {
      emit(CreateRideError('Error al cargar datos: ${e.toString()}'));
    }
  }


  void selectVehicle(Vehicle vehicle) {
    if (state is CreateRideReady) {
      emit((state as CreateRideReady).copyWith(selectedVehicle: vehicle));
    }
  }

  void selectZone(Zone zone) {
    if (state is CreateRideReady) {
      emit((state as CreateRideReady).copyWith(selectedZone: zone));
    }
  }

  Future<void> createRide({
    required String source,
    required String destination,
    required String date,
    required String departureTime,
    required String type,
    required double price,
  }) async {
    if (state is! CreateRideReady) return;
    final current = state as CreateRideReady;

    if (current.selectedVehicle == null || current.selectedZone == null) {
      emit(CreateRideError('Selecciona un vehículo y una zona'));
      return;
    }

    emit(current.copyWith(isSubmitting: true));

    try {
      final userId   = await _repository.getUserIdFromToken();
      final driverId = await _repository.getDriverIdByUserId(userId);

      await _repository.createRide(
        Ride(
          driverId:      driverId,
          vehicleId:     current.selectedVehicle!.id,
          zoneId:        current.selectedZone!.id,
          source:        source.trim(),
          destination:   destination.trim(),
          date:          date,
          departureTime: departureTime,
          state:         'OFERTADO',
          type:          type,
          price:         price,
        ),
      );

      emit(CreateRideSuccess());
    } catch (e) {
      emit(CreateRideError('Error al publicar viaje: ${e.toString()}'));
    }
  }
}