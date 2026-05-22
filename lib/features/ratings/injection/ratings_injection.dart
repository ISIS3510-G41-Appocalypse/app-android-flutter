import 'package:get_it/get_it.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/network_checker.dart';
import '../data/data_sources/ratings_remote_data_source.dart';
import '../data/data_sources/ratings_remote_data_source_impl.dart';
import '../data/local/ratings_draft_storage.dart';
import '../data/repositories/ratings_repository_impl.dart';
import '../domain/repositories/ratings_repository.dart';
import '../domain/usecases/submit_driver_rating.dart';
import '../domain/usecases/submit_rider_ratings.dart';
import '../presentation/view_model/ratings_cubit.dart';

final sl = GetIt.instance;

void setupRatingsInjection() {
  sl.registerLazySingleton<RatingsRemoteDataSource>(
    () => RatingsRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<RatingsRepository>(
    () => RatingsRepositoryImpl(
      remoteDataSource: sl<RatingsRemoteDataSource>(),
      networkChecker: sl<NetworkChecker>(),
    ),
  );
  sl.registerFactory(() => SubmitDriverRating(sl<RatingsRepository>()));
  sl.registerFactory(() => SubmitRiderRatings(sl<RatingsRepository>()));
  sl.registerFactory(
    () => RatingsCubit(
      submitDriverRatingUseCase: sl<SubmitDriverRating>(),
      submitRiderRatingsUseCase: sl<SubmitRiderRatings>(),
      draftStorage: sl<RatingsDraftStorage>(),
      networkChecker: sl<NetworkChecker>(),
    ),
  );
}
