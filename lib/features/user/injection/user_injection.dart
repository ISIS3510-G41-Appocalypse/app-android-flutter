import 'package:get_it/get_it.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/network_checker.dart';
import '../data/datasources/local/user_datasource_local.dart';
import '../data/datasources/local/user_datasource_local_storage.dart';
import '../data/datasources/remote/user_datasource_remote.dart';
import '../data/datasources/remote/user_datasource_remote_supabase.dart';
import '../data/repositories/user_repository_impl.dart';
import '../domain/usecases/get_cached_user.dart';
import '../domain/usecases/load_user.dart';
import '../domain/usecases/load_profiles.dart';
import '../presentation/view_model/user_cubit.dart';

final sl = GetIt.instance;

Future<void> setupUserInjection() async {
  final userDataSourceLocal = UserDataSourceLocalStorage();
  await userDataSourceLocal.initialize();
  sl.registerLazySingleton<UserDataSourceLocal>(() => userDataSourceLocal);

  sl.registerLazySingleton<UserDataSourceRemote>(
    () => UserDataSourceRemoteSupabase(
      dio: sl<DioClient>().dio,
    ),
  );
  sl.registerLazySingleton<UserRepositoryImpl>(
    () => UserRepositoryImpl(
      dataSourceRemote: sl<UserDataSourceRemote>(),
      networkChecker: sl<NetworkChecker>(),
      dataSourceLocal: sl<UserDataSourceLocal>(),
    ),
  );
  sl.registerFactory(() => GetCachedUser(sl<UserRepositoryImpl>()));
  sl.registerFactory(() => LoadUser(sl<UserRepositoryImpl>()));
  sl.registerFactory(() => LoadProfiles(sl<UserRepositoryImpl>()));
  sl.registerFactory(
    () => UserCubit(
      getCachedUserUseCase: sl<GetCachedUser>(),
      loadUserUseCase: sl<LoadUser>(),
      loadProfilesUseCase: sl<LoadProfiles>(),
    ),
  );
}
