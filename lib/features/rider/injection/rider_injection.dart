import 'package:get_it/get_it.dart';
import '../../../core/network/dio_client.dart';
import '../data/datasources/reservation_remote_datasource_supabase.dart';
import '../data/repositories/reservation_repository_impl.dart';
import '../domain/usecases/get_active_reservation_for_rider.dart';
import '../presentation/viewmodel/reservation_cubit.dart';
import '../data/datasources/reservation_remote_datasource.dart';

final sl = GetIt.instance;

void setupRiderInjection() {
  sl.registerLazySingleton<ReservationRemoteDataSource>(
    () => ReservationRemoteDataSourceSupabase(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ReservationRepositoryImpl>(
    () => ReservationRepositoryImpl(remoteDataSource: sl<ReservationRemoteDataSource>()),
  );
  sl.registerFactory<GetActiveReservationForRider>(
    () => GetActiveReservationForRider(sl<ReservationRepositoryImpl>()),
  );
  sl.registerFactory<ReservationCubit>(
    () => ReservationCubit(getActiveReservationForRider: sl<GetActiveReservationForRider>()),
  );
}
