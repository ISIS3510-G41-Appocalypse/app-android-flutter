import 'package:get_it/get_it.dart';
import '../core/network/dio_client.dart';
import '../core/storage/session_storage.dart';
import '../features/auth/injection/auth_injection.dart';
import '../features/driver_rides/injection/driver_rides_injection.dart';
import '../features/ride_offers/injection/ride_offers_injection.dart';
import '../features/user/injection/user_injection.dart';

final sl = GetIt.instance;

void setupLocator() {
  sl.registerLazySingleton<SessionStorage>(() => SessionStorage());
  sl.registerLazySingleton<DioClient>(() => DioClient(sessionStorage: sl()));

  setupAuthInjection();
  setupDriverRidesInjection();
  setupRideOffersInjection();
  setupUserInjection();
}
