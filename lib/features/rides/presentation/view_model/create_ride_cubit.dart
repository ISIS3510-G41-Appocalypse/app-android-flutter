import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/models/ride_model.dart';
import '../../data/repositories/rides_repository_impl.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/zone.dart';
import '../../domain/repositories/rides_offline_sync_repository.dart';
import 'create_ride_state.dart';

class CreateRideCubit extends Cubit<CreateRideState> {
  final RidesRepositoryImpl repository;
  final RidesOfflineSyncRepository syncRepository;
  final int _userId;

  StreamSubscription<RideSyncResult>? _connectivitySubscription;

  CreateRideCubit({
    required DioClient client,
    required this.syncRepository,
    required int userId,
  })  : repository = RidesRepositoryImpl(client: client),
        _userId = userId,
        super(const CreateRideState()) {
    _connectivitySubscription = syncRepository
        .listenToConnectivityChanges()
        .listen(_handleConnectivitySyncResult);
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName es requerido';
    return null;
  }

  String? validateVehicleSelected(Vehicle? vehicle) {
    if (vehicle == null) return 'Selecciona un vehiculo';
    return null;
  }

  String? validateZoneSelected(Zone? zone) {
    if (zone == null) return 'Selecciona una zona';
    return null;
  }

  Future<void> loadInitialData() async {
    emit(
      state.copyWith(
        status: CreateRideStatus.loading,
        clearMessage: true,
      ),
    );

    try {
      final driverId = await repository.getDriverIdByUserId(_userId);

      final results = await Future.wait([
        repository.getVehiclesByDriver(driverId),
        repository.getZones(),
      ]);

      final vehicles = results[0] as List<Vehicle>;
      final zones = results[1] as List<Zone>;
      final pendingDraft = _restorePendingDraft();

      if (vehicles.isEmpty) {
        emit(
          state.copyWith(
            status: CreateRideStatus.error,
            message: 'No tienes vehiculos registrados.',
            vehicles: const [],
            zones: const [],
            clearSelectedVehicle: true,
            clearSelectedZone: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: CreateRideStatus.ready,
          vehicles: vehicles,
          zones: zones,
          selectedVehicle: _findVehicleById(vehicles, pendingDraft?.vehicleId),
          selectedZone: _findZoneById(zones, pendingDraft?.zoneId),
          restoredDraft: pendingDraft,
          hasPendingRideForm: pendingDraft != null,
          navigateToDriverRides: false,
          clearMessage: true,
        ),
      );

      await syncPendingRideIfPossible();
    } catch (e) {
      emit(
        state.copyWith(
          status: CreateRideStatus.error,
          message: 'Error al cargar datos: ${e.toString()}',
        ),
      );
    }
  }

  void selectVehicle(Vehicle vehicle) {
    emit(
      state.copyWith(
        selectedVehicle: vehicle,
        status: CreateRideStatus.ready,
      ),
    );
  }

  void selectZone(Zone zone) {
    emit(
      state.copyWith(
        selectedZone: zone,
        status: CreateRideStatus.ready,
      ),
    );
  }

  Future<void> createRide({
    required String source,
    required String destination,
    required String date,
    required String departureTime,
    required String type,
    required double price,
  }) async {
    if (!state.isReadyLike) return;

    if (state.selectedVehicle == null || state.selectedZone == null) {
      emit(
        state.copyWith(
          status: CreateRideStatus.error,
          message: 'Selecciona un vehiculo y una zona',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: CreateRideStatus.submitting,
        clearMessage: true,
        navigateToDriverRides: false,
      ),
    );

    try {
      final driverId = await repository.getDriverIdByUserId(_userId);

      final ride = RideModel(
        driverId: driverId,
        vehicleId: state.selectedVehicle!.id,
        zoneId: state.selectedZone!.id,
        source: source.trim(),
        destination: destination.trim(),
        date: date,
        departureTime: departureTime,
        state: 'OFERTADO',
        type: type,
        price: price,
      );

      final result = await syncRepository.createRideWithOfflineSupport(ride);
      _applySyncResult(
        result,
        fallbackDraft: RideFormDraft(
          vehicleId: ride.vehicleId,
          zoneId: ride.zoneId,
          source: ride.source,
          destination: ride.destination,
          date: ride.date,
          departureTime: ride.departureTime,
          type: ride.type,
          price: ride.price.toString(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CreateRideStatus.error,
          message: 'Error al publicar viaje: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> syncPendingRideIfPossible() async {
    if (!state.hasPendingRideForm) return;

    final hasInternet = await syncRepository.networkChecker.hasInternet;
    if (!hasInternet) return;

    emit(
      state.copyWith(
        status: CreateRideStatus.syncing,
        message: 'Conexion restaurada. Sincronizando viaje...',
      ),
    );

    final result = await syncRepository.syncPendingRide();
    _applySyncResult(result);
  }

  void consumeMessage() {
    if (state.message == null && !state.navigateToDriverRides) return;

    final nextStatus = switch (state.status) {
      CreateRideStatus.success => CreateRideStatus.ready,
      CreateRideStatus.error => CreateRideStatus.ready,
      CreateRideStatus.offlineQueued => CreateRideStatus.ready,
      CreateRideStatus.syncing => CreateRideStatus.ready,
      _ => state.status,
    };

    emit(
      state.copyWith(
        status: nextStatus,
        clearMessage: true,
        navigateToDriverRides: false,
      ),
    );
  }

  void consumeRestoredDraft() {
    if (state.restoredDraft == null) return;

    emit(
      state.copyWith(
        clearRestoredDraft: true,
      ),
    );
  }

  RideFormDraft? _restorePendingDraft() {
    final pendingForm = syncRepository.getPendingRideForm();
    if (pendingForm == null) return null;

    return RideFormDraft(
      vehicleId: pendingForm['vehicle_id'] as int?,
      zoneId: pendingForm['zone_id'] as int?,
      source: pendingForm['source'] as String? ?? '',
      destination: pendingForm['destination'] as String? ?? '',
      date: pendingForm['date'] as String? ?? '',
      departureTime: pendingForm['departure_time'] as String? ?? '',
      type: pendingForm['type'] as String? ?? 'TO_UNIVERSITY',
      price: (pendingForm['price'] as num?)?.toString() ?? '',
    );
  }

  Vehicle? _findVehicleById(List<Vehicle> vehicles, int? vehicleId) {
    if (vehicleId == null) return null;
    for (final vehicle in vehicles) {
      if (vehicle.id == vehicleId) return vehicle;
    }
    return null;
  }

  Zone? _findZoneById(List<Zone> zones, int? zoneId) {
    if (zoneId == null) return null;
    for (final zone in zones) {
      if (zone.id == zoneId) return zone;
    }
    return null;
  }

  void _handleConnectivitySyncResult(RideSyncResult result) {
    if (isClosed) return;
    _applySyncResult(result);
  }

  void _applySyncResult(
    RideSyncResult result, {
    RideFormDraft? fallbackDraft,
  }) {
    switch (result.status) {
      case RideSyncStatus.success:
        emit(
          state.copyWith(
            status: CreateRideStatus.success,
            message: result.message,
            hasPendingRideForm: false,
            clearRestoredDraft: true,
            navigateToDriverRides: true,
          ),
        );
        break;
      case RideSyncStatus.waitingForConnection:
        emit(
          state.copyWith(
            status: CreateRideStatus.offlineQueued,
            message: result.message,
            hasPendingRideForm: true,
            restoredDraft: fallbackDraft ?? state.restoredDraft,
          ),
        );
        break;
      case RideSyncStatus.syncing:
        emit(
          state.copyWith(
            status: CreateRideStatus.syncing,
            message: result.message,
            hasPendingRideForm: true,
          ),
        );
        break;
      case RideSyncStatus.networkError:
      case RideSyncStatus.serverError:
      case RideSyncStatus.error:
        emit(
          state.copyWith(
            status: CreateRideStatus.error,
            message: result.message,
            hasPendingRideForm:
                syncRepository.getPendingRideForm() != null,
          ),
        );
        break;
    }
  }

  @override
  Future<void> close() async {
    await _connectivitySubscription?.cancel();
    return super.close();
  }
}
