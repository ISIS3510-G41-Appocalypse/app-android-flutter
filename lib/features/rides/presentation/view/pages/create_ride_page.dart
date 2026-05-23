import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/layout/header.dart';
import '../../../../../core/layout/navigation_bar.dart' as navigation_layout;
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/performance/performance_time_tracker.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../user/presentation/view_model/user_cubit.dart';
import '../../../../user/presentation/view_model/user_state.dart';
import '../../../../rider_rides/presentation/view_model/rider_rides_cubit.dart';
import '../../../../rider_rides/presentation/view_model/rider_rides_state.dart';
import '../../../domain/repositories/rides_offline_sync_repository.dart';
import '../../view_model/create_ride_cubit.dart';
import '../widgets/create_ride_form.dart';
import '../widgets/no_driver_permission_state.dart';

final sl = GetIt.instance;

class CreateRidePage extends StatelessWidget {
  const CreateRidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserCubit>().state;
    final user = userState.user;
    final isDriver = user?.driver != null;

    if (userState.status == UserStatus.loading && user == null) {
      return const Scaffold(
        backgroundColor: AppColors.slate900,
        appBar: Header(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!isDriver) {
      return Scaffold(
        backgroundColor: AppColors.slate900,
        appBar: const Header(),
        body: const SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 120),
            child: NoDriverPermissionState(),
          ),
        ),
        bottomNavigationBar: const navigation_layout.NavigationBar(
          selectedItem: navigation_layout.NavigationBarItem.rides,
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CreateRideCubit(
            client: sl<DioClient>(),
            syncRepository: sl<RidesOfflineSyncRepository>(),
            performanceTimeTracker: sl<PerformanceTimeTracker>(),
            driverId: user!.driver!.id,
          )..loadInitialData(),
        ),
        BlocProvider(
          create: (_) => sl<RiderRidesCubit>()
            ..loadActiveRide(riderId: user!.rider?.id),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.slate900,
        appBar: const Header(),
        body: SafeArea(
          top: false,
          child: BlocListener<UserCubit, UserState>(
            listenWhen: (previous, current) => previous.user != current.user,
            listener: (context, userState) {
              context.read<RiderRidesCubit>().loadActiveRide(
                riderId: userState.user?.rider?.id,
              );
            },
            child: ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                overscroll: false,
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Ofertar viaje',
                            style: AppTextStyles.primary.copyWith(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Completa los detalles para compartir tu ruta con la comunidad.',
                            style: AppTextStyles.primary.copyWith(
                              color: AppColors.slate400,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<RiderRidesCubit, RiderRidesState>(
                      builder: (context, riderRideState) {
                        final hasActiveReservation =
                            riderRideState.status == RiderRidesStatus.success;
                        final isCheckingReservation =
                            riderRideState.status == RiderRidesStatus.loading;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasActiveReservation ||
                                isCheckingReservation) ...[
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF1F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFECACA),
                                  ),
                                ),
                                child: Text(
                                  isCheckingReservation
                                      ? 'Verificando si ya tienes una reserva activa como pasajero...'
                                      : 'Debes cancelar o finalizar tu reserva activa antes de publicar un viaje.',
                                  style: AppTextStyles.primary.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFB91C1C),
                                  ),
                                ),
                              ),
                            ],
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    offset: const Offset(5, 5),
                                  ),
                                ],
                              ),
                              child: const CreateRideForm(),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.teal600.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.teal600.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            color: AppColors.teal600,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tu oferta será visible para todos los estudiantes en tu ruta.',
                              style: AppTextStyles.primary.copyWith(
                                fontSize: 12,
                                color: AppColors.teal600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: const navigation_layout.NavigationBar(
          selectedItem: navigation_layout.NavigationBarItem.rides,
        ),
      ),
    );
  }
}
