import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../../../core/network/network_checker.dart';
import '../../../../core/storage/ride_form_offline_storage.dart';
import '../../data/datasources/rides_remote_datasource.dart';
import '../../data/models/ride_model.dart';

/// Estados posibles para la sincronización de viajes offline
enum RideSyncStatus {
  /// Viaje creado exitosamente
  success,

  /// Esperando conexión a internet
  waitingForConnection,

  /// Sincronizando datos con el servidor
  syncing,

  /// Error de conexión de red
  networkError,

  /// Error en el servidor
  serverError,

  /// Error genérico
  error,
}

/// Resultado de operación de sincronización
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

/// Repositorio que maneja la creación de viajes considerando conectividad
class RidesOfflineSyncRepository {
  final NetworkChecker networkChecker;
  final RideFormOfflineStorage offlineStorage;
  final RidesRemoteDatasource remoteDatasource;

  RidesOfflineSyncRepository({
    required this.networkChecker,
    required this.offlineStorage,
    required this.remoteDatasource,
  });

  /// Crea un viaje con manejo automático de offline
  /// Si hay internet: envía inmediatamente
  /// Si no hay internet: guarda localmente y espera conexión
  Future<RideSyncResult> createRideWithOfflineSupport(RideModel ride) async {
    final hasInternet = await networkChecker.hasInternet;

    if (hasInternet) {
      try {
        final createdRide = await remoteDatasource.createRide(ride);
        // Limpiar cualquier formulario pendiente si existe
        if (offlineStorage.hasPendingRideForm()) {
          await offlineStorage.clearPendingRideForm();
        }
        return RideSyncResult(
          status: RideSyncStatus.success,
          message: 'Viaje creado exitosamente',
          rideData: createdRide,
        );
      } catch (e) {
        return RideSyncResult(
          status: RideSyncStatus.serverError,
          message: 'Error al crear viaje: ${e.toString()}',
        );
      }
    } else {
      // Guardar formulario para sincronización posterior
      await offlineStorage.savePendingRideForm(ride.toJson());
      return RideSyncResult(
        status: RideSyncStatus.waitingForConnection,
        message: 'Sin conexión. El viaje se creará cuando vuelva la conexión.',
      );
    }
  }

  /// Obtiene un formulario pendiente guardado
  Map<String, dynamic>? getPendingRideForm() {
    return offlineStorage.getPendingRideForm();
  }

  /// Sincroniza automáticamente cuando vuelve el internet
  /// Se debe llamar cuando se detecte que la conectividad volvió
  Future<RideSyncResult> syncPendingRide() async {
    final hasInternet = await networkChecker.hasInternet;

    if (!hasInternet) {
      return RideSyncResult(
        status: RideSyncStatus.networkError,
        message: 'Aún no hay conexión a internet',
      );
    }

    final pendingFormData = offlineStorage.getPendingRideForm();
    if (pendingFormData == null) {
      return RideSyncResult(
        status: RideSyncStatus.error,
        message: 'No hay viaje pendiente para sincronizar',
      );
    }

    try {
      final rideModel = RideModel.fromJson(pendingFormData);
      final createdRide = await remoteDatasource.createRide(rideModel);
      await offlineStorage.clearPendingRideForm();

      return RideSyncResult(
        status: RideSyncStatus.success,
        message: 'Viaje creado exitosamente después de reconectar',
        rideData: createdRide,
      );
    } catch (e) {
      return RideSyncResult(
        status: RideSyncStatus.serverError,
        message: 'Error al sincronizar viaje: ${e.toString()}',
      );
    }
  }

  /// Limpia el formulario pendiente (cuando el usuario cierra completamente la app)
  Future<void> clearPendingRide() async {
    await offlineStorage.clearPendingRideForm();
  }

  /// Listener para sincronizar automáticamente cuando vuelve internet
  /// Retorna un stream de estados de sincronización
  Stream<RideSyncResult> listenToConnectivityChanges() async* {
    await for (final result in InternetConnection().onStatusChange) {
      final isConnected = result == InternetStatus.connected;

      if (isConnected && offlineStorage.hasPendingRideForm()) {
        yield RideSyncResult(
          status: RideSyncStatus.syncing,
          message: 'Conexión restaurada. Sincronizando viaje...',
        );

        final syncResult = await syncPendingRide();
        yield syncResult;
      }
    }
  }
}
