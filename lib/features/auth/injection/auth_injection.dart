import 'package:get_it/get_it.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../data/datasources/local/auth_datasource_local.dart';
import '../data/datasources/local/auth_datasource_local_storage.dart';
import '../data/datasources/remote/auth_datasource_remote.dart';
import '../data/datasources/remote/auth_datasource_remote_supabase.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/usecases/login_user.dart';
import '../domain/usecases/logout_user.dart';
import '../domain/usecases/restore_session.dart';
import '../presentation/view_model/auth_cubit.dart';

final sl = GetIt.instance;

void setupAuthInjection() {
  sl.registerLazySingleton<AuthDataSourceLocal>(
    () => AuthDataSourceLocalStorage(
      tokenStorage: sl<TokenStorage>(),
    ),
  );
  sl.registerLazySingleton<AuthDataSourceRemote>(
    () => AuthDataSourceRemoteSupabase(
      dio: sl<DioClient>().dio,
    ),
  );
  sl.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(
      dataSourceRemote: sl<AuthDataSourceRemote>(),
      dataSourceLocal: sl<AuthDataSourceLocal>(),
    ),
  );
  sl.registerFactory(() => LoginUser(sl<AuthRepositoryImpl>()));
  sl.registerFactory(() => LogoutUser(sl<AuthRepositoryImpl>()));
  sl.registerFactory(() => RestoreSession(sl<AuthRepositoryImpl>()));
  sl.registerFactory(() => AuthCubit(
        loginUser: sl<LoginUser>(),
        logoutUser: sl<LogoutUser>(),
        restoreSessionUseCase: sl<RestoreSession>(),
      ));
}
