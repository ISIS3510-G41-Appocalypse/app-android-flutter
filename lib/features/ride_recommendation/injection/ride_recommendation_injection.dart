import 'package:get_it/get_it.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/network_checker.dart';
import '../data/datasources/remote/ride_recommendation_remote_datasource.dart';
import '../data/datasources/remote/ride_recommendation_remote_datasource_supabase.dart';
import '../data/repositories/ride_recommendation_repository_impl.dart';
import '../domain/usecases/get_ride_recommendation.dart';

final sl = GetIt.instance;

void setupRideRecommendationInjection() {
  sl.registerLazySingleton<RideRecommendationRemoteDataSource>(
    () => RideRecommendationRemoteDataSourceSupabase(
      dio: sl<DioClient>().dio,
    ),
  );
  sl.registerLazySingleton<RideRecommendationRepositoryImpl>(
    () => RideRecommendationRepositoryImpl(
      remoteDataSource: sl<RideRecommendationRemoteDataSource>(),
      networkChecker: sl<NetworkChecker>(),
    ),
  );
  sl.registerFactory(
    () => GetRideRecommendation(sl<RideRecommendationRepositoryImpl>()),
  );
}
