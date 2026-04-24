import 'package:get_it/get_it.dart';

import '../../../core/network/dio_client.dart';
import '../data/datasources/user_datasource_remote.dart';
import '../data/datasources/user_datasource_remote_supabase.dart';
import '../data/repositories/user_repository_remote.dart';
import '../domain/usecases/get_driver_profile.dart';
import '../domain/usecases/get_rider_profile.dart';
import '../presentation/view_model/user_cubit.dart';

final sl = GetIt.instance;

void setupUserInjection() {
  sl.registerLazySingleton<UserDataSourceRemote>(
    () => UserDataSourceRemoteSupabase(
      dio: sl<DioClient>().dio,
    ),
  );
  sl.registerLazySingleton<UserRepositoryRemote>(
    () => UserRepositoryRemote(
      dataSourceRemote: sl<UserDataSourceRemote>(),
    ),
  );
  sl.registerFactory(
    () => GetRiderProfile(sl<UserRepositoryRemote>()),
  );
  sl.registerFactory(
    () => GetDriverProfile(sl<UserRepositoryRemote>()),
  );
  sl.registerFactory(
    () => UserCubit(
      getRiderProfile: sl<GetRiderProfile>(),
      getDriverProfile: sl<GetDriverProfile>(),
    ),
  );
}
