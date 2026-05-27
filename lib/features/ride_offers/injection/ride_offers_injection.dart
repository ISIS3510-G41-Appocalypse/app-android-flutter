import 'package:get_it/get_it.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/network_checker.dart';
import '../../../core/performance/performance_time_tracker.dart';
import '../data/local/ride_offer_filters_storage.dart';
import '../data/data_sources/ride_offers_remote_datasource.dart';
import '../data/data_sources/ride_offers_remote_datasource_impl.dart';
import '../data/repositories/ride_offers_repository_impl.dart';
import '../domain/usecases/get_ride_offers.dart';
import '../domain/usecases/get_zones.dart';
import '../../payments/domain/usecases/has_blocking_payments.dart';
import '../../ride_recommendation/domain/usecases/get_ride_recommendation.dart';
import '../../rider_rides/domain/usecases/create_reservation.dart';
import '../presentation/view_model/ride_offers_cubit.dart';

final sl = GetIt.instance;

void setupRideOffersInjection() {
  sl.registerLazySingleton<RideOffersRemoteDataSource>(
    () => RideOffersRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<RideOffersRepositoryImpl>(
    () => RideOffersRepositoryImpl(
      remoteDataSource: sl<RideOffersRemoteDataSource>(),
      networkChecker: sl<NetworkChecker>(),
    ),
  );
  sl.registerFactory(() => GetRideOffers(sl<RideOffersRepositoryImpl>()));
  sl.registerFactory(() => GetZones(sl<RideOffersRepositoryImpl>()));
  sl.registerFactory(
    () => RideOffersCubit(
      getRideOffers: sl<GetRideOffers>(),
      getZones: sl<GetZones>(),
      createReservation: sl<CreateReservation>(),
      getRideRecommendation: sl<GetRideRecommendation>(),
      hasBlockingPayments: sl<HasBlockingPayments>(),
      performanceTimeTracker: sl<PerformanceTimeTracker>(),
      filtersStorage: sl<RideOfferFiltersStorage>(),
    ),
  );
}
