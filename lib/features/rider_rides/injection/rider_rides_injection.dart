import 'package:get_it/get_it.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/network_checker.dart';
import '../data/data_sources/rider_rides_remote_data_source.dart';
import '../data/data_sources/rider_rides_remote_data_source_impl.dart';
import '../data/repositories/rider_rides_repository_impl.dart';
import '../domain/usecases/cancel_reservation.dart';
import '../domain/usecases/create_reservation.dart';
import '../domain/usecases/get_active_rider_ride.dart';
import '../presentation/view_model/rider_rides_cubit.dart';

final sl = GetIt.instance;

void setupRiderRidesInjection() {
  sl.registerLazySingleton<RiderRidesRemoteDataSource>(
    () => RiderRidesRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<RiderRidesRepositoryImpl>(
    () => RiderRidesRepositoryImpl(
      remoteDataSource: sl<RiderRidesRemoteDataSource>(),
      networkChecker: sl<NetworkChecker>(),
    ),
  );
  sl.registerFactory(() => GetActiveRiderRide(sl<RiderRidesRepositoryImpl>()));
  sl.registerFactory(() => CancelReservation(sl<RiderRidesRepositoryImpl>()));
  sl.registerFactory(() => CreateReservation(sl<RiderRidesRepositoryImpl>()));
  sl.registerFactory(
    () => RiderRidesCubit(
      getActiveRiderRide: sl<GetActiveRiderRide>(),
      cancelReservationUseCase: sl<CancelReservation>(),
    ),
  );
}
