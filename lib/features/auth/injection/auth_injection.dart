import 'package:get_it/get_it.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../data/datasources/auth_datasource_remote_supabase.dart';
import '../data/repositories/auth_repository_remote.dart';
import '../domain/usecases/login_user.dart';
import '../domain/usecases/logout_user.dart';
import '../domain/usecases/restore_session.dart';
import '../presentation/view_model/auth_cubit.dart';

final sl = GetIt.instance;

void setupAuthInjection() {
  sl.registerLazySingleton<AuthDataSourceRemoteSupabase>(
    () => AuthDataSourceRemoteSupabase(
      dio: sl<DioClient>().dio,
      tokenStorage: sl<TokenStorage>(),
    ),
  );
  sl.registerLazySingleton<AuthRepositoryRemote>(
    () => AuthRepositoryRemote(
      dataSourceRemote: sl<AuthDataSourceRemoteSupabase>(),
      tokenStorage: sl<TokenStorage>(),
    ),
  );
  sl.registerFactory(() => LoginUser(sl<AuthRepositoryRemote>()));
  sl.registerFactory(() => LogoutUser(sl<AuthRepositoryRemote>()));
  sl.registerFactory(() => RestoreSession(sl<AuthRepositoryRemote>()));
  sl.registerFactory(() => AuthCubit(
        loginUser: sl<LoginUser>(),
        logoutUser: sl<LogoutUser>(),
        restoreSession: sl<RestoreSession>(),
      ));
}