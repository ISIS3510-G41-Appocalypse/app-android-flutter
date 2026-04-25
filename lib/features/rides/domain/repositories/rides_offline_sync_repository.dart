import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/network_checker.dart';
import '../../../../core/storage/ride_form_offline_storage.dart';
import '../../data/datasources/rides_remote_datasource.dart';
import '../../data/models/ride_model.dart';

enum RideSyncStatus {
  success,
  networkError,
  serverError,
  error,
}

class RideSyncResult {
  final RideSyncStatus status;
  final String message;
  final RideModel? rideData;

  RideSyncResult({
    required this.status,
    required this.message,
    this.rideData,
  });
}

class RidesOfflineSyncRepository {
  final NetworkChecker networkChecker;
  final RideFormOfflineStorage offlineStorage;
  final RidesRemoteDatasource remoteDatasource;

  RidesOfflineSyncRepository({
    required this.networkChecker,
    required this.offlineStorage,
    required this.remoteDatasource,
  });

  Future<RideSyncResult> createRideWithOfflineSupport(RideModel ride) async {
    final hasInternet = await networkChecker.hasInternet;

    if (!hasInternet) {
      await offlineStorage.saveDraftRideForm(ride.toJson());
      return RideSyncResult(
        status: RideSyncStatus.networkError,
        message:
            'No tienes internet. El formulario quedo guardado para que lo completes o lo publiques cuando vuelva la conexion.',
      );
    }

    try {
      final createdRide = await remoteDatasource.createRide(ride);
      await clearStoredRideForm();

      return RideSyncResult(
        status: RideSyncStatus.success,
        message: 'Viaje creado exitosamente.',
        rideData: createdRide,
      );
    } catch (e) {
      if (_isNetworkError(e)) {
        await offlineStorage.saveDraftRideForm(ride.toJson());
        return RideSyncResult(
          status: RideSyncStatus.networkError,
          message:
              'No se pudo publicar el viaje por falta de internet. El formulario quedo guardado y podras intentarlo de nuevo cuando vuelva la conexion.',
        );
      }

      return RideSyncResult(
        status: RideSyncStatus.serverError,
        message: 'No se pudo publicar el viaje por un error del servidor.',
      );
    }
  }

  Map<String, dynamic>? getRestorableRideForm() {
    return offlineStorage.getDraftRideForm();
  }

  Future<void> saveRideDraft(Map<String, dynamic> formData) async {
    await offlineStorage.saveDraftRideForm(formData);
  }

  Future<void> clearRideDraft() async {
    await offlineStorage.clearDraftRideForm();
  }

  Future<void> clearStoredRideForm() async {
    if (offlineStorage.hasDraftRideForm()) {
      await offlineStorage.clearDraftRideForm();
    }
    if (offlineStorage.hasPendingRideForm()) {
      await offlineStorage.clearPendingRideForm();
    }
  }

  bool _isNetworkError(Object error) {
    if (error is SocketException) {
      return true;
    }

    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.error is SocketException;
    }

    return false;
  }
}
