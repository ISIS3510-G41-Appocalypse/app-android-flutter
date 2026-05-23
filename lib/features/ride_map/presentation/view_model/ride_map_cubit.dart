import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/location/device_location_service.dart';
import '../../../../core/notifications/local_notification_service.dart';
import '../../domain/entities/ride_map_location.dart';
import '../../domain/usecases/get_ride_map_locations.dart';
import '../../domain/usecases/is_ride_map_location_sharing_enabled.dart';
import '../../domain/usecases/publish_ride_map_location.dart';
import '../../domain/usecases/stop_ride_map_location_sharing.dart';
import 'ride_map_state.dart';

class RideMapCubit extends Cubit<RideMapState> {
  static const Duration _realtimeRefreshInterval = Duration(seconds: 20);
  static const double _minimumPublishDistanceMeters = 20;

  final DeviceLocationService locationService;
  final GetRideMapLocations getRideMapLocations;
  final PublishRideMapLocation publishRideMapLocation;
  final StopRideMapLocationSharing stopRideMapLocationSharing;
  final IsRideMapLocationSharingEnabled isRideMapLocationSharingEnabled;
  final LocalNotificationService localNotificationService;
  final Set<String> _nearbyNotifiedRideIds = {};
  final Map<String, _PublishedLocation> _lastPublishedLocations = {};
  Timer? _realtimeTimer;
  bool _isRealtimeRefreshRunning = false;

  RideMapCubit({
    required this.locationService,
    required this.getRideMapLocations,
    required this.publishRideMapLocation,
    required this.stopRideMapLocationSharing,
    required this.isRideMapLocationSharingEnabled,
    required this.localNotificationService,
  }) : super(RideMapState.initial());

  void _emitIfOpen(RideMapState nextState) {
    if (!isClosed) {
      emit(nextState);
    }
  }

  Future<void> startDriverRideMapRealtime({
    required String rideId,
    required int? driverUserId,
    required Map<int, String> passengerNamesByUserId,
  }) async {
    stopRealtimeUpdates();

    await loadDriverRideMap(
      rideId: rideId,
      driverUserId: driverUserId,
      passengerNamesByUserId: passengerNamesByUserId,
    );

    if (isClosed) return;

    _realtimeTimer = Timer.periodic(_realtimeRefreshInterval, (_) {
      _runRealtimeRefresh(
        () => loadDriverRideMap(
          rideId: rideId,
          driverUserId: driverUserId,
          passengerNamesByUserId: passengerNamesByUserId,
          showLoading: false,
        ),
      );
    });
  }

  Future<void> startRiderRideMapRealtime({
    required String rideId,
    required int? riderUserId,
    required int driverUserId,
    required String driverName,
  }) async {
    stopRealtimeUpdates();

    await loadRiderRideMap(
      rideId: rideId,
      riderUserId: riderUserId,
      driverUserId: driverUserId,
      driverName: driverName,
    );

    if (isClosed) return;

    _realtimeTimer = Timer.periodic(_realtimeRefreshInterval, (_) {
      _runRealtimeRefresh(
        () => loadRiderRideMap(
          rideId: rideId,
          riderUserId: riderUserId,
          driverUserId: driverUserId,
          driverName: driverName,
          showLoading: false,
        ),
      );
    });
  }

  void stopRealtimeUpdates() {
    _realtimeTimer?.cancel();
    _realtimeTimer = null;
    _isRealtimeRefreshRunning = false;
  }

  Future<void> _runRealtimeRefresh(Future<void> Function() refresh) async {
    if (_isRealtimeRefreshRunning || isClosed) return;

    _isRealtimeRefreshRunning = true;
    try {
      await refresh();
    } finally {
      _isRealtimeRefreshRunning = false;
    }
  }

  Future<void> loadDriverRideMap({
    required String rideId,
    required int? driverUserId,
    required Map<int, String> passengerNamesByUserId,
    bool showLoading = true,
  }) async {
    final keepCurrentMap =
        !showLoading &&
        (state.status == RideMapStatus.success ||
            state.status == RideMapStatus.empty);

    if (showLoading || !keepCurrentMap) {
      _emitIfOpen(
        state.copyWith(
          status: RideMapStatus.loading,
          locations: const [],
          clearMessage: true,
          isOffline: false,
          isPermissionBlocked: false,
        ),
      );
    }

    double? driverLatitude;
    double? driverLongitude;

    try {
      final currentLocation = await locationService.getCurrentLocation();
      driverLatitude = currentLocation.latitude;
      driverLongitude = currentLocation.longitude;

      if (driverUserId != null) {
        await _publishUserLocationIfMoved(
          rideId: rideId,
          userId: driverUserId,
          latitude: driverLatitude,
          longitude: driverLongitude,
        );
      }
    } on LocationPermissionException catch (e) {
      if (keepCurrentMap) {
        _emitIfOpen(
          state.copyWith(message: e.message, isPermissionBlocked: true),
        );
        return;
      }

      _emitIfOpen(
        state.copyWith(
          status: RideMapStatus.error,
          message: e.message,
          isPermissionBlocked: true,
        ),
      );
      return;
    } catch (_) {
      _emitIfOpen(
        state.copyWith(
          message:
              'No pudimos obtener tu ubicacion actual. Mostraremos datos disponibles.',
        ),
      );
    }

    final result = await getRideMapLocations(
      rideId: rideId,
      passengerNamesByUserId: passengerNamesByUserId,
      originLatitude: driverLatitude,
      originLongitude: driverLongitude,
    );

    result.fold(
      (failure) {
        if (keepCurrentMap) {
          _emitIfOpen(
            state.copyWith(
              message: failure.message,
              isOffline: failure is NetworkFailure,
              driverLatitude: driverLatitude,
              driverLongitude: driverLongitude,
            ),
          );
          return;
        }

        _emitIfOpen(
          state.copyWith(
            status: RideMapStatus.error,
            message: failure.message,
            isOffline: failure is NetworkFailure,
            driverLatitude: driverLatitude,
            driverLongitude: driverLongitude,
          ),
        );
      },
      (locations) {
        _emitIfOpen(
          state.copyWith(
            status: locations.isEmpty
                ? RideMapStatus.empty
                : RideMapStatus.success,
            locations: locations,
            driverLatitude: driverLatitude,
            driverLongitude: driverLongitude,
            message: locations.isEmpty
                ? 'Aun no hay ubicaciones recientes de pasajeros confirmados.'
                : null,
            clearMessage: locations.isNotEmpty,
            isOffline: false,
          ),
        );
      },
    );
  }

  Future<void> shareCurrentUserLocation({
    required String rideId,
    required int? userId,
  }) async {
    if (userId == null) {
      return;
    }

    _emitIfOpen(
      state.copyWith(
        status: RideMapStatus.loading,
        clearMessage: true,
        isOffline: false,
        isPermissionBlocked: false,
      ),
    );

    try {
      final currentLocation = await locationService.getCurrentLocation();
      final result = await _publishUserLocationIfMoved(
        rideId: rideId,
        userId: userId,
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
        force: true,
      );

      result.fold(
        (failure) {
          _emitIfOpen(
            state.copyWith(
              status: RideMapStatus.error,
              message: failure.message,
              isOffline: failure is NetworkFailure,
            ),
          );
        },
        (_) {
          _emitIfOpen(
            state.copyWith(
              status: RideMapStatus.success,
              message: 'Ubicacion compartida para este viaje.',
              isOffline: false,
            ),
          );
        },
      );
    } on LocationPermissionException catch (e) {
      _emitIfOpen(
        state.copyWith(
          status: RideMapStatus.error,
          message: e.message,
          isPermissionBlocked: true,
        ),
      );
    } catch (_) {
      _emitIfOpen(
        state.copyWith(
          status: RideMapStatus.error,
          message: 'No pudimos compartir tu ubicacion actual.',
        ),
      );
    }
  }

  Future<void> loadRiderRideMap({
    required String rideId,
    required int? riderUserId,
    required int driverUserId,
    required String driverName,
    bool showLoading = true,
  }) async {
    final keepCurrentMap =
        !showLoading &&
        (state.status == RideMapStatus.success ||
            state.status == RideMapStatus.empty);

    if (showLoading || !keepCurrentMap) {
      _emitIfOpen(
        state.copyWith(
          status: RideMapStatus.loading,
          locations: const [],
          clearMessage: true,
          isOffline: false,
          isPermissionBlocked: false,
        ),
      );
    }

    double? riderLatitude;
    double? riderLongitude;

    try {
      if (riderUserId != null) {
        final canShareLocation = await _canCurrentUserShareLocation(
          rideId: rideId,
          userId: riderUserId,
        );

        if (!canShareLocation) {
          stopRealtimeUpdates();
          _emitIfOpen(
            state.copyWith(
              status: RideMapStatus.empty,
              locations: const [],
              driverLatitude: null,
              driverLongitude: null,
              message: 'Ya fuiste recogido. El mapa se detuvo.',
              isOffline: false,
              isPermissionBlocked: false,
            ),
          );
          return;
        }
      }

      final currentLocation = await locationService.getCurrentLocation();
      riderLatitude = currentLocation.latitude;
      riderLongitude = currentLocation.longitude;

      if (riderUserId != null) {
        await _publishUserLocationIfMoved(
          rideId: rideId,
          userId: riderUserId,
          latitude: riderLatitude,
          longitude: riderLongitude,
        );
      }
    } on LocationPermissionException catch (e) {
      if (keepCurrentMap) {
        _emitIfOpen(
          state.copyWith(message: e.message, isPermissionBlocked: true),
        );
        return;
      }

      _emitIfOpen(
        state.copyWith(
          status: RideMapStatus.error,
          message: e.message,
          isPermissionBlocked: true,
        ),
      );
      return;
    } catch (_) {
      _emitIfOpen(
        state.copyWith(
          message:
              'No pudimos obtener tu ubicacion actual. Mostraremos datos disponibles.',
        ),
      );
    }

    if (driverUserId <= 0) {
      _emitIfOpen(
        state.copyWith(
          status: RideMapStatus.empty,
          locations: const [],
          driverLatitude: riderLatitude,
          driverLongitude: riderLongitude,
          message:
              'No pudimos identificar al conductor para mostrarlo en el mapa.',
          isOffline: false,
        ),
      );
      return;
    }

    final result = await getRideMapLocations(
      rideId: rideId,
      passengerNamesByUserId: {driverUserId: driverName},
      originLatitude: riderLatitude,
      originLongitude: riderLongitude,
    );

    result.fold(
      (failure) {
        if (keepCurrentMap) {
          _emitIfOpen(
            state.copyWith(
              message: failure.message,
              isOffline: failure is NetworkFailure,
              driverLatitude: riderLatitude,
              driverLongitude: riderLongitude,
            ),
          );
          return;
        }

        _emitIfOpen(
          state.copyWith(
            status: RideMapStatus.error,
            message: failure.message,
            isOffline: failure is NetworkFailure,
            driverLatitude: riderLatitude,
            driverLongitude: riderLongitude,
          ),
        );
      },
      (locations) {
        _syncNearbyDriverNotification(
          rideId: rideId,
          driverName: driverName,
          locations: locations,
        );

        _emitIfOpen(
          state.copyWith(
            status: locations.isEmpty
                ? RideMapStatus.empty
                : RideMapStatus.success,
            locations: locations,
            driverLatitude: riderLatitude,
            driverLongitude: riderLongitude,
            message: locations.isEmpty
                ? 'Aun no hay ubicacion reciente del conductor.'
                : null,
            clearMessage: locations.isNotEmpty,
            isOffline: false,
          ),
        );
      },
    );
  }

  Future<void> markPassengerPickedUp({
    required String rideId,
    required int userId,
  }) async {
    final result = await stopRideMapLocationSharing(
      rideId: rideId,
      userId: userId,
    );

    result.fold(
      (failure) {
        _emitIfOpen(state.copyWith(message: failure.message));
      },
      (_) {
        final nextLocations = state.locations
            .where((location) => location.userId != userId)
            .toList();

        if (nextLocations.isEmpty) {
          stopRealtimeUpdates();
          _emitIfOpen(
            state.copyWith(
              status: RideMapStatus.empty,
              locations: const [],
              message:
                  'Todos los pasajeros fueron recogidos. El mapa se detuvo.',
              clearMessage: false,
              isOffline: false,
            ),
          );
          return;
        }

        _emitIfOpen(
          state.copyWith(
            status: RideMapStatus.success,
            locations: nextLocations,
            message: 'Pasajero marcado como recogido.',
            isOffline: false,
          ),
        );
      },
    );
  }

  Future<bool> _canCurrentUserShareLocation({
    required String rideId,
    required int userId,
  }) async {
    final result = await isRideMapLocationSharingEnabled(
      rideId: rideId,
      userId: userId,
    );

    return result.getOrElse(() => true);
  }

  void _syncNearbyDriverNotification({
    required String rideId,
    required String driverName,
    required List<RideMapLocation> locations,
  }) {
    if (locations.isEmpty) {
      _nearbyNotifiedRideIds.remove(rideId);
      return;
    }

    final driverLocation = locations.first;
    final distanceMeters = driverLocation.distanceMeters;

    if (distanceMeters != null && distanceMeters <= 200) {
      if (_nearbyNotifiedRideIds.add(rideId)) {
        unawaited(
          localNotificationService.showDriverNearbyNotification(
            rideId: rideId,
            driverName: driverName,
            distanceMeters: distanceMeters,
          ),
        );
      }
      return;
    }

    _nearbyNotifiedRideIds.remove(rideId);
  }

  Future<Either<Failure, void>> _publishUserLocationIfMoved({
    required String rideId,
    required int userId,
    required double latitude,
    required double longitude,
    bool force = false,
  }) async {
    final key = '$rideId|$userId';
    final lastPublishedLocation = _lastPublishedLocations[key];

    if (!force && lastPublishedLocation != null) {
      final distanceMeters = locationService.distanceBetween(
        startLatitude: lastPublishedLocation.latitude,
        startLongitude: lastPublishedLocation.longitude,
        endLatitude: latitude,
        endLongitude: longitude,
      );

      if (distanceMeters < _minimumPublishDistanceMeters) {
        return const Right(null);
      }
    }

    final result = await publishRideMapLocation(
      rideId: rideId,
      userId: userId,
      latitude: latitude,
      longitude: longitude,
    );

    result.fold((_) {}, (_) {
      _lastPublishedLocations[key] = _PublishedLocation(
        latitude: latitude,
        longitude: longitude,
      );
    });

    return result;
  }

  @override
  Future<void> close() {
    stopRealtimeUpdates();
    return super.close();
  }
}

class _PublishedLocation {
  final double latitude;
  final double longitude;

  const _PublishedLocation({required this.latitude, required this.longitude});
}
