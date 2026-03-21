import 'package:get_it/get_it.dart';

import '../../../core/network/dio_client.dart';
import '../data/data_sources/ride_offers_remote_datasource.dart';
import '../data/data_sources/ride_offers_remote_datasource_impl.dart';
import '../data/repositories/ride_offers_repository_impl.dart';
import '../domain/usecases/get_ride_offers.dart';
import '../domain/usecases/get_zones.dart';
import '../presentation/view_model/ride_offers_cubit.dart';

import '../data/repositories/ride_navigation_repository_impl.dart';
import '../domain/usecases/start_ride_navigation.dart';

final sl = GetIt.instance;

void setupRideOffersInjection() {
  sl.registerLazySingleton<RideOffersRemoteDataSource>(
    () => RideOffersRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<RideOffersRepositoryImpl>(
    () => RideOffersRepositoryImpl(
      remoteDataSource: sl<RideOffersRemoteDataSource>(),
    ),
  );
  sl.registerFactory(() => GetRideOffers(sl<RideOffersRepositoryImpl>()));
  sl.registerFactory(() => GetZones(sl<RideOffersRepositoryImpl>()));
  sl.registerFactory(
    () => RideOffersCubit(
      getRideOffers: sl<GetRideOffers>(),
      getZones: sl<GetZones>(),
      startRideNavigation: sl<StartRideNavigation>(),
    ),
  );

  sl.registerLazySingleton<RideNavigationRepositoryImpl>(
    () => RideNavigationRepositoryImpl(),
  );

  sl.registerFactory(
    () => StartRideNavigation(sl<RideNavigationRepositoryImpl>()),
  );
}
