import 'package:get_it/get_it.dart';

import '../../../core/network/dio_client.dart';
import '../data/datasources/remote/user_datasource_remote.dart';
import '../data/datasources/remote/user_datasource_remote_supabase.dart';
import '../data/repositories/user_repository_impl.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/usecases/load_user.dart';
import '../presentation/view_model/user_cubit.dart';

final sl = GetIt.instance;

void setupUserInjection() {
  sl.registerLazySingleton<UserDataSourceRemote>(
    () => UserDataSourceRemoteSupabase(
      dio: sl<DioClient>().dio,
    ),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      dataSourceRemote: sl<UserDataSourceRemote>(),
    ),
  );
  sl.registerFactory(
    () => LoadUser(sl<UserRepository>()),
  );
  sl.registerFactory(
    () => UserCubit(
      loadUserUseCase: sl<LoadUser>(),
    ),
  );
}
