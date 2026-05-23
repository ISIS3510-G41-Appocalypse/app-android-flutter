import 'package:get_it/get_it.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/network_checker.dart';
import '../../../core/notifications/local_notification_service.dart';
import '../data/data_sources/payments_remote_data_source.dart';
import '../data/data_sources/payments_remote_data_source_impl.dart';
import '../data/local/payments_cache_storage.dart';
import '../data/repositories/payments_repository_impl.dart';
import '../domain/repositories/payments_repository.dart';
import '../domain/usecases/confirm_payment.dart';
import '../domain/usecases/create_pending_payments_for_ride.dart';
import '../domain/usecases/get_driver_payments.dart';
import '../domain/usecases/get_rider_payments.dart';
import '../domain/usecases/has_blocking_payments.dart';
import '../domain/usecases/mark_payment_for_confirmation.dart';
import '../domain/usecases/reject_payment.dart';
import '../presentation/view_model/payments_cubit.dart';

final sl = GetIt.instance;

Future<void> setupPaymentsInjection() async {
  final cacheStorage = PaymentsCacheStorage();
  await cacheStorage.initialize();
  sl.registerLazySingleton<PaymentsCacheStorage>(() => cacheStorage);

  sl.registerLazySingleton<PaymentsRemoteDataSource>(
    () => PaymentsRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<PaymentsRepository>(
    () => PaymentsRepositoryImpl(
      remoteDataSource: sl<PaymentsRemoteDataSource>(),
      cacheStorage: sl<PaymentsCacheStorage>(),
      networkChecker: sl<NetworkChecker>(),
    ),
  );
  sl.registerFactory(() => GetDriverPayments(sl<PaymentsRepository>()));
  sl.registerFactory(() => GetRiderPayments(sl<PaymentsRepository>()));
  sl.registerFactory(() => HasBlockingPayments(sl<PaymentsRepository>()));
  sl.registerFactory(
    () => CreatePendingPaymentsForRide(sl<PaymentsRepository>()),
  );
  sl.registerFactory(
    () => MarkPaymentForConfirmation(sl<PaymentsRepository>()),
  );
  sl.registerFactory(() => ConfirmPayment(sl<PaymentsRepository>()));
  sl.registerFactory(() => RejectPayment(sl<PaymentsRepository>()));
  sl.registerFactory(
    () => PaymentsCubit(
      getDriverPayments: sl<GetDriverPayments>(),
      getRiderPayments: sl<GetRiderPayments>(),
      markPaymentForConfirmation: sl<MarkPaymentForConfirmation>(),
      confirmPaymentUseCase: sl<ConfirmPayment>(),
      rejectPaymentUseCase: sl<RejectPayment>(),
      localNotificationService: sl<LocalNotificationService>(),
      networkChecker: sl<NetworkChecker>(),
    ),
  );
}
