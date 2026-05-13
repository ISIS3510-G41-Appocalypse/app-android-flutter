import 'package:get_it/get_it.dart';

import '../../../core/location/device_location_service.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/network_checker.dart';
import '../../../core/notifications/local_notification_service.dart';
import '../data/data_sources/ride_map_remote_data_source.dart';
import '../data/data_sources/ride_map_remote_data_source_impl.dart';
import '../data/local/ride_map_location_cache.dart';
import '../data/repositories/ride_map_repository_impl.dart';
import '../domain/repositories/ride_map_repository.dart';
import '../domain/usecases/get_ride_map_locations.dart';
import '../domain/usecases/publish_ride_map_location.dart';
import '../presentation/view_model/ride_map_cubit.dart';

final sl = GetIt.instance;

Future<void> setupRideMapInjection() async {
  sl.registerLazySingleton<DeviceLocationService>(
    () => DeviceLocationService(),
  );

  final cache = RideMapLocationCache();
  await cache.initialize();
  sl.registerLazySingleton<RideMapLocationCache>(() => cache);

  sl.registerLazySingleton<RideMapRemoteDataSource>(
    () => RideMapRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<RideMapRepository>(
    () => RideMapRepositoryImpl(
      remoteDataSource: sl<RideMapRemoteDataSource>(),
      cache: sl<RideMapLocationCache>(),
      networkChecker: sl<NetworkChecker>(),
      locationService: sl<DeviceLocationService>(),
    ),
  );
  sl.registerFactory(() => GetRideMapLocations(sl<RideMapRepository>()));
  sl.registerFactory(() => PublishRideMapLocation(sl<RideMapRepository>()));
  sl.registerFactory(
    () => RideMapCubit(
      locationService: sl<DeviceLocationService>(),
      getRideMapLocations: sl<GetRideMapLocations>(),
      publishRideMapLocation: sl<PublishRideMapLocation>(),
      localNotificationService: sl<LocalNotificationService>(),
    ),
  );
}
