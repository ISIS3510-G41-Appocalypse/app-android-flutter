import 'package:get_it/get_it.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/network_checker.dart';
import '../../../core/performance/performance_time_tracker.dart';
import '../../../core/storage/session_storage.dart';
import '../data/datasources/local/auth_datasource_local.dart';
import '../data/datasources/local/auth_datasource_local_storage.dart';
import '../data/datasources/remote/auth_datasource_remote.dart';
import '../data/datasources/remote/auth_datasource_remote_supabase.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/usecases/login_user.dart';
import '../domain/usecases/logout_user.dart';
import '../domain/usecases/get_register_zones.dart';
import '../domain/usecases/signup_user.dart';
import '../domain/usecases/verify_session.dart';
import '../presentation/view_model/auth_cubit.dart';

final sl = GetIt.instance;

void setupAuthInjection() {
  sl.registerLazySingleton<AuthDataSourceLocal>(
    () => AuthDataSourceLocalStorage(
      sessionStorage: sl<SessionStorage>(),
    ),
  );
  sl.registerLazySingleton<AuthDataSourceRemote>(
    () => AuthDataSourceRemoteSupabase(
      dio: sl<DioClient>().dio,
      performanceTimeTracker: sl<PerformanceTimeTracker>(),
    ),
  );
  sl.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(
      dataSourceRemote: sl<AuthDataSourceRemote>(),
      dataSourceLocal: sl<AuthDataSourceLocal>(),
      networkChecker: sl<NetworkChecker>(),
    ),
  );
  sl.registerFactory(() => GetRegisterZones(sl<AuthRepositoryImpl>()));
  sl.registerFactory(() => SignupUser(sl<AuthRepositoryImpl>()));
  sl.registerFactory(() => LoginUser(sl<AuthRepositoryImpl>()));
  sl.registerFactory(() => LogoutUser(sl<AuthRepositoryImpl>()));
  sl.registerFactory(() => VerifySession(sl<AuthRepositoryImpl>()));
      sl.registerFactory(() => AuthCubit(
        getRegisterZones: sl<GetRegisterZones>(),
        signupUser: sl<SignupUser>(),
        loginUser: sl<LoginUser>(),
        logoutUser: sl<LogoutUser>(),
        verifySessionUseCase: sl<VerifySession>(),
        performanceTimeTracker: sl<PerformanceTimeTracker>(),
      ));
}
