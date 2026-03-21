import 'package:get_it/get_it.dart';
import '../core/network/dio_client.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/injection/auth_injection.dart';
import '../features/ride_offers/injection/ride_offers_injection.dart';

final sl = GetIt.instance;

void setupLocator() {
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<DioClient>(() => DioClient(tokenStorage: sl()));

  setupAuthInjection();
  setupRideOffersInjection();
}