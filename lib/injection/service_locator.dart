import 'package:get_it/get_it.dart';
import '../core/notifications/local_notification_service.dart';
import '../core/network/dio_client.dart';
import '../core/network/network_checker.dart';
import '../core/performance/performance_time_tracker.dart';
import '../core/storage/session_storage.dart';
import '../features/auth/injection/auth_injection.dart';
import '../features/driver_rides/injection/driver_rides_injection.dart';
import '../features/payments/injection/payments_injection.dart';
import '../features/ride_offers/injection/ride_offers_injection.dart';
import '../features/ride_map/injection/ride_map_injection.dart';
import '../features/ride_recommendation/injection/ride_recommendation_injection.dart';
import '../features/ratings/injection/ratings_injection.dart';
import '../features/ratings/data/local/ratings_draft_storage.dart';
import '../features/rider_rides/injection/rider_rides_injection.dart';
import '../features/user/injection/user_injection.dart';
import '../core/storage/ride_form_offline_storage.dart';
import '../features/rides/data/datasources/rides_remote_datasource.dart';
import '../features/rides/domain/repositories/rides_offline_sync_repository.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  final localNotificationService = LocalNotificationService();
  await localNotificationService.initialize();
  sl.registerLazySingleton<LocalNotificationService>(
    () => localNotificationService,
  );

  sl.registerLazySingleton<SessionStorage>(() => SessionStorage());
  sl.registerLazySingleton<NetworkChecker>(() => NetworkChecker());
  sl.registerLazySingleton<DioClient>(() => DioClient(sessionStorage: sl()));
  sl.registerLazySingleton<PerformanceTimeTracker>(
    () => PerformanceTimeTracker(
      dio: sl<DioClient>().dio,
      networkChecker: sl<NetworkChecker>(),
    ),
  );
  sl.registerLazySingleton<RidesRemoteDatasource>(
    () => RidesRemoteDatasource(
      client: sl<DioClient>(),
      performanceTimeTracker: sl<PerformanceTimeTracker>(),
    ),
  );

  final offlineStorage = RideFormOfflineStorage();
  await offlineStorage.initialize();
  sl.registerLazySingleton<RideFormOfflineStorage>(() => offlineStorage);

  final ratingsDraftStorage = RatingsDraftStorage();
  await ratingsDraftStorage.initialize();
  sl.registerLazySingleton<RatingsDraftStorage>(() => ratingsDraftStorage);

  sl.registerLazySingleton<RidesOfflineSyncRepository>(
    () => RidesOfflineSyncRepository(
      networkChecker: sl<NetworkChecker>(),
      offlineStorage: sl<RideFormOfflineStorage>(),
      remoteDatasource: sl<RidesRemoteDatasource>(),
    ),
  );

  setupAuthInjection();
  await setupRideMapInjection();
  setupPaymentsInjection();
  setupDriverRidesInjection();
  setupRatingsInjection();
  setupRideRecommendationInjection();
  setupRiderRidesInjection();
  setupRideOffersInjection();
  setupUserInjection();
}
