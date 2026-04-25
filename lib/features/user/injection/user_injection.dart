import 'package:get_it/get_it.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/network_checker.dart';
import '../data/datasources/remote/user_datasource_remote.dart';
import '../data/datasources/remote/user_datasource_remote_supabase.dart';
import '../data/repositories/user_repository_impl.dart';
import '../domain/usecases/load_user.dart';
import '../domain/usecases/load_profiles.dart';
import '../presentation/view_model/user_cubit.dart';

final sl = GetIt.instance;

void setupUserInjection() {
  sl.registerLazySingleton<UserDataSourceRemote>(
    () => UserDataSourceRemoteSupabase(
      dio: sl<DioClient>().dio,
    ),
  );
  sl.registerLazySingleton<UserRepositoryImpl>(
    () => UserRepositoryImpl(
      dataSourceRemote: sl<UserDataSourceRemote>(),
      networkChecker: sl<NetworkChecker>(),
    ),
  );
  sl.registerFactory(() => LoadUser(sl<UserRepositoryImpl>()));
  sl.registerFactory(() => LoadProfiles(sl<UserRepositoryImpl>()));
  sl.registerFactory(
    () => UserCubit(
      loadUserUseCase: sl<LoadUser>(),
      loadProfilesUseCase: sl<LoadProfiles>(),
    ),
  );
}
