import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/performance/performance_features.dart';
import '../../../../core/performance/performance_time_tracker.dart';
import '../../data/models/ride_model.dart';
import '../../data/repositories/rides_repository_impl.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/zone.dart';
import '../../domain/repositories/rides_offline_sync_repository.dart';
import 'create_ride_state.dart';

class CreateRideCubit extends Cubit<CreateRideState> {
  final RidesRepositoryImpl repository;
  final RidesOfflineSyncRepository syncRepository;
  final PerformanceTimeTracker performanceTimeTracker;
  final int _driverId;

  CreateRideCubit({
    required DioClient client,
    required this.syncRepository,
    required this.performanceTimeTracker,
    required int driverId,
  }) : repository = RidesRepositoryImpl(
         client: client,
         performanceTimeTracker: performanceTimeTracker,
       ),
       _driverId = driverId,
       super(const CreateRideState());

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
    emit(state.copyWith(status: CreateRideStatus.loading, clearMessage: true));
    final pendingDraft = restoreDraft();

    try {
      final results = await Future.wait([
        repository.getVehiclesByDriver(_driverId),
        repository.getZones(),
      ]);

      final vehicles = results[0] as List<Vehicle>;
      final zones = results[1] as List<Zone>;

      if (vehicles.isEmpty) {
        emit(
          state.copyWith(
            status: CreateRideStatus.error,
            message: 'No tienes vehiculos registrados.',
            vehicles: const [],
            zones: const [],
            clearSelectedVehicle: true,
            clearSelectedZone: true,
            restoredDraft: pendingDraft,
            shouldAnnounceRestoredDraft: pendingDraft != null,
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
          shouldAnnounceRestoredDraft: pendingDraft != null,
          hasPendingRideForm: false,
          navigateToDriverRides: false,
          clearMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CreateRideStatus.error,
          message: 'Error al cargar datos: ${e.toString()}',
          restoredDraft: pendingDraft,
          shouldAnnounceRestoredDraft: pendingDraft != null,
        ),
      );
    }
  }

  void selectVehicle(Vehicle vehicle) {
    emit(
      state.copyWith(selectedVehicle: vehicle, status: CreateRideStatus.ready),
    );
  }

  void selectZone(Zone zone) {
    emit(state.copyWith(selectedZone: zone, status: CreateRideStatus.ready));
  }

  Future<void> createRide({
    required String source,
    required String destination,
    required String date,
    required String departureTime,
    required String type,
    required double price,
    Stopwatch? createRideFrontEndStopwatch,
  }) async {
    if (!state.isReadyLike) return;

    final stopwatch = createRideFrontEndStopwatch ?? (Stopwatch()..start());

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
      final ride = RideModel(
        driverId: _driverId,
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
      stopwatch.stop();

      if (result.status != RideSyncStatus.networkError) {
        unawaited(
          performanceTimeTracker.track(
            feature: PerformanceFeatures.createRide,
            duration: stopwatch.elapsedMilliseconds.toDouble(),
            source: PerformanceSources.frontEnd,
          ),
        );
      }

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
          price: _formatDraftPrice(ride.price),
        ),
      );
    } catch (e) {
      stopwatch.stop();

      unawaited(
        performanceTimeTracker.track(
          feature: PerformanceFeatures.createRide,
          duration: stopwatch.elapsedMilliseconds.toDouble(),
          source: PerformanceSources.frontEnd,
        ),
      );

      emit(
        state.copyWith(
          status: CreateRideStatus.error,
          message: 'Error al publicar viaje: ${e.toString()}',
        ),
      );
    }
  }

  void consumeMessage() {
    if (state.message == null && !state.navigateToDriverRides) return;

    final nextStatus = switch (state.status) {
      CreateRideStatus.success => CreateRideStatus.ready,
      CreateRideStatus.error => CreateRideStatus.ready,
      CreateRideStatus.offlineQueued => CreateRideStatus.ready,
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
    if (state.restoredDraft == null && !state.shouldAnnounceRestoredDraft) {
      return;
    }

    emit(
      state.copyWith(
        clearRestoredDraft: true,
        shouldAnnounceRestoredDraft: false,
      ),
    );
  }

  Future<void> saveDraft({
    int? vehicleId,
    int? zoneId,
    required String source,
    required String destination,
    required String date,
    required String departureTime,
    required String type,
    required String price,
  }) async {
    final hasUsefulData =
        source.trim().isNotEmpty ||
        destination.trim().isNotEmpty ||
        date.trim().isNotEmpty ||
        departureTime.trim().isNotEmpty ||
        price.trim().isNotEmpty ||
        vehicleId != null ||
        zoneId != null;

    if (!hasUsefulData) {
      return;
    }

    await syncRepository.saveRideDraft({
      'driver_id': _driverId,
      'vehicle_id': vehicleId,
      'zone_id': zoneId,
      'source': source.trim(),
      'destination': destination.trim(),
      'date': date.trim(),
      'departure_time': departureTime.trim(),
      'state': 'OFERTADO',
      'type': type,
      'price': double.tryParse(price.trim()) ?? 0,
    });
  }

  RideFormDraft? restoreDraft() {
    final pendingForm = syncRepository.getRestorableRideForm();
    if (pendingForm == null) return null;

    return RideFormDraft(
      vehicleId: _toIntOrNull(pendingForm['vehicle_id']),
      zoneId: _toIntOrNull(pendingForm['zone_id']),
      source: pendingForm['source'] as String? ?? '',
      destination: pendingForm['destination'] as String? ?? '',
      date: pendingForm['date'] as String? ?? '',
      departureTime: pendingForm['departure_time'] as String? ?? '',
      type: pendingForm['type'] as String? ?? 'TO_UNIVERSITY',
      price: _formatDraftPrice(pendingForm['price']),
    );
  }

  String _formatDraftPrice(Object? value) {
    if (value == null) return '';

    if (value is int) {
      return value.toString();
    }

    if (value is double) {
      return value.truncateToDouble() == value
          ? value.toInt().toString()
          : value.toString();
    }

    if (value is num) {
      final asDouble = value.toDouble();
      return asDouble.truncateToDouble() == asDouble
          ? asDouble.toInt().toString()
          : asDouble.toString();
    }

    return value.toString();
  }

  int? _toIntOrNull(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
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

  void _applySyncResult(RideSyncResult result, {RideFormDraft? fallbackDraft}) {
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
      case RideSyncStatus.networkError:
        emit(
          state.copyWith(
            status: CreateRideStatus.offlineQueued,
            message: result.message,
            hasPendingRideForm: false,
            restoredDraft: fallbackDraft ?? state.restoredDraft,
            shouldAnnounceRestoredDraft: false,
          ),
        );
        break;
      case RideSyncStatus.serverError:
      case RideSyncStatus.error:
        emit(
          state.copyWith(
            status: CreateRideStatus.error,
            message: result.message,
            hasPendingRideForm: false,
          ),
        );
        break;
    }
  }
}
