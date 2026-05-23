import 'package:get_it/get_it.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/network_checker.dart';
import '../../../core/realtime/supabase_realtime_service.dart';
import '../../payments/domain/usecases/create_pending_payments_for_ride.dart';
import '../data/data_sources/driver_rides_remote_data_source.dart';
import '../data/data_sources/driver_rides_remote_data_source_impl.dart';
import '../data/repositories/driver_rides_repository_impl.dart';
import '../domain/usecases/accept_reservation.dart';
import '../domain/usecases/get_active_driver_ride.dart';
import '../domain/usecases/reject_reservation.dart';
import '../domain/usecases/update_ride_state.dart';
import '../presentation/view_model/driver_rides_cubit.dart';

final sl = GetIt.instance;

void setupDriverRidesInjection() {
  sl.registerLazySingleton<DriverRidesRemoteDataSource>(
    () => DriverRidesRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<DriverRidesRepositoryImpl>(
    () => DriverRidesRepositoryImpl(
      remoteDataSource: sl<DriverRidesRemoteDataSource>(),
      networkChecker: sl<NetworkChecker>(),
    ),
  );
  sl.registerFactory(
    () => GetActiveDriverRide(sl<DriverRidesRepositoryImpl>()),
  );
  sl.registerFactory(() => UpdateRideState(sl<DriverRidesRepositoryImpl>()));
  sl.registerFactory(() => AcceptReservation(sl<DriverRidesRepositoryImpl>()));
  sl.registerFactory(() => RejectReservation(sl<DriverRidesRepositoryImpl>()));
  sl.registerFactory(
    () => DriverRidesCubit(
      getActiveDriverRide: sl<GetActiveDriverRide>(),
      updateRideState: sl<UpdateRideState>(),
      acceptReservationUseCase: sl<AcceptReservation>(),
      rejectReservationUseCase: sl<RejectReservation>(),
      createPendingPaymentsForRide: sl<CreatePendingPaymentsForRide>(),
      realtimeService: sl<SupabaseRealtimeService>(),
    ),
  );
}
