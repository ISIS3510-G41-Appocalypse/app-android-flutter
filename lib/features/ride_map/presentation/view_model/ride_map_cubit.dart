import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/location/device_location_service.dart';
import '../../domain/usecases/get_ride_map_locations.dart';
import '../../domain/usecases/publish_ride_map_location.dart';
import 'ride_map_state.dart';

class RideMapCubit extends Cubit<RideMapState> {
  final DeviceLocationService locationService;
  final GetRideMapLocations getRideMapLocations;
  final PublishRideMapLocation publishRideMapLocation;

  RideMapCubit({
    required this.locationService,
    required this.getRideMapLocations,
    required this.publishRideMapLocation,
  }) : super(RideMapState.initial());

  Future<void> loadDriverRideMap({
    required String rideId,
    required int? driverUserId,
    required Map<int, String> passengerNamesByUserId,
  }) async {
    emit(
      state.copyWith(
        status: RideMapStatus.loading,
        locations: const [],
        clearMessage: true,
        isOffline: false,
        isPermissionBlocked: false,
      ),
    );

    double? driverLatitude;
    double? driverLongitude;

    try {
      final currentLocation = await locationService.getCurrentLocation();
      driverLatitude = currentLocation.latitude;
      driverLongitude = currentLocation.longitude;

      if (driverUserId != null) {
        await publishRideMapLocation(
          rideId: rideId,
          userId: driverUserId,
          latitude: driverLatitude,
          longitude: driverLongitude,
        );
      }
    } on LocationPermissionException catch (e) {
      emit(
        state.copyWith(
          status: RideMapStatus.error,
          message: e.message,
          isPermissionBlocked: true,
        ),
      );
      return;
    } catch (_) {
      emit(
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
        emit(
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
        emit(
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

    emit(
      state.copyWith(
        status: RideMapStatus.loading,
        clearMessage: true,
        isOffline: false,
        isPermissionBlocked: false,
      ),
    );

    try {
      final currentLocation = await locationService.getCurrentLocation();
      final result = await publishRideMapLocation(
        rideId: rideId,
        userId: userId,
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: RideMapStatus.error,
              message: failure.message,
              isOffline: failure is NetworkFailure,
            ),
          );
        },
        (_) {
          emit(
            state.copyWith(
              status: RideMapStatus.success,
              message: 'Ubicacion compartida para este viaje.',
              isOffline: false,
            ),
          );
        },
      );
    } on LocationPermissionException catch (e) {
      emit(
        state.copyWith(
          status: RideMapStatus.error,
          message: e.message,
          isPermissionBlocked: true,
        ),
      );
    } catch (_) {
      emit(
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
  }) async {
    emit(
      state.copyWith(
        status: RideMapStatus.loading,
        locations: const [],
        clearMessage: true,
        isOffline: false,
        isPermissionBlocked: false,
      ),
    );

    double? riderLatitude;
    double? riderLongitude;

    try {
      final currentLocation = await locationService.getCurrentLocation();
      riderLatitude = currentLocation.latitude;
      riderLongitude = currentLocation.longitude;

      if (riderUserId != null) {
        await publishRideMapLocation(
          rideId: rideId,
          userId: riderUserId,
          latitude: riderLatitude,
          longitude: riderLongitude,
        );
      }
    } on LocationPermissionException catch (e) {
      emit(
        state.copyWith(
          status: RideMapStatus.error,
          message: e.message,
          isPermissionBlocked: true,
        ),
      );
      return;
    } catch (_) {
      emit(
        state.copyWith(
          message:
              'No pudimos obtener tu ubicacion actual. Mostraremos datos disponibles.',
        ),
      );
    }

    if (driverUserId <= 0) {
      emit(
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
        emit(
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
        emit(
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
}
