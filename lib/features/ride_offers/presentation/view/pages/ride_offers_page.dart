import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../../app/routes.dart';
import '../../../../../core/layout/header.dart' as header_layout;
import '../../../../../core/layout/navigation_bar.dart' as navigation_layout;
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/view/widgets/auth_session_listener.dart';
import '../../../../driver_rides/presentation/view_model/driver_rides_cubit.dart';
import '../../../../driver_rides/presentation/view_model/driver_rides_state.dart';
import '../../../../user/domain/entities/user_role.dart';
import '../../../../user/presentation/view_model/user_cubit.dart';
import '../../../../user/presentation/view_model/user_state.dart';
import '../../view_model/ride_offers_cubit.dart';
import '../../view_model/ride_offers_state.dart';
import '../widgets/ride_offers_filter_section.dart';
import '../widgets/ride_offers_header_section.dart';
import '../widgets/ride_offers_list_section.dart';

class RideOffersPage extends StatefulWidget {
  const RideOffersPage({super.key});

  @override
  State<RideOffersPage> createState() => _RideOffersPageState();
}

class _RideOffersPageState extends State<RideOffersPage> {
  final GetIt _sl = GetIt.instance;
  late final RideOffersCubit _cubit;
  late final DriverRidesCubit _driverRidesCubit;

  @override
  void initState() {
    super.initState();

    final userState = context.read<UserCubit>().state;
    final user = userState.user;
    final activeRole = userState.activeRole;
    final preferredZoneId = user?.zoneId.toString();

    _cubit = _sl<RideOffersCubit>()
      ..loadInitialData(preferredZoneId: preferredZoneId);
    _driverRidesCubit = _sl<DriverRidesCubit>()
      ..loadActiveRide(
        driverId: activeRole == UserRole.driver ? user?.driver?.id : null,
      );
  }

  @override
  void dispose() {
    _cubit.close();
    _driverRidesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _driverRidesCubit),
      ],
      child: AuthSessionListener(
        child: Scaffold(
          backgroundColor: AppColors.slate900,
          appBar: const header_layout.Header(),
          body: SafeArea(
            top: false,
            child: BlocListener<UserCubit, UserState>(
              listenWhen: (previous, current) =>
                  previous.activeRole != current.activeRole ||
                  previous.user != current.user,
              listener: (context, userState) {
                final driverId = userState.activeRole == UserRole.driver
                    ? userState.user?.driver?.id
                    : null;

                _driverRidesCubit.loadActiveRide(driverId: driverId);
              },
              child: BlocConsumer<RideOffersCubit, RideOffersState>(
                listenWhen: (previous, current) =>
                    !previous.reservationCreated && current.reservationCreated,
                listener: (context, state) async {
                  await context.read<UserCubit>().changeRole(UserRole.rider);

                  if (!context.mounted) {
                    return;
                  }

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.riderRides,
                    (route) => false,
                  );
                },
                builder: (context, state) {
                  final cubit = context.read<RideOffersCubit>();

                  return ScrollConfiguration(
                    behavior: const MaterialScrollBehavior().copyWith(
                      overscroll: false,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          BlocBuilder<UserCubit, UserState>(
                            builder: (context, userState) {
                              final isDriverMode =
                                  userState.activeRole == UserRole.driver;

                              return BlocBuilder<
                                DriverRidesCubit,
                                DriverRidesState
                              >(
                                builder: (context, driverRideState) {
                                  final hasActiveRide =
                                      isDriverMode &&
                                      driverRideState.status ==
                                          DriverRidesStatus.success;
                                  final isCheckingAvailability =
                                      isDriverMode &&
                                      driverRideState.status ==
                                          DriverRidesStatus.loading;

                                  return RideOffersHeaderSection(
                                    showPublishAction: isDriverMode,
                                    isPublishEnabled:
                                        !hasActiveRide &&
                                        !isCheckingAvailability,
                                    helperText: isCheckingAvailability
                                        ? 'Verificando si ya tienes un viaje activo...'
                                        : hasActiveRide
                                        ? 'Ya tienes un viaje activo como conductor. '
                                              'Debes cancelarlo o finalizarlo antes de publicar otro.'
                                        : null,
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          RideOffersFiltersSection(
                            zones: state.zones,
                            zoneId: state.filters.zoneId,
                            date: state.filters.date,
                            time: state.filters.time,
                            type: state.filters.type,
                            onZoneChanged: cubit.updateZoneId,
                            onDateChanged: cubit.updateDate,
                            onTimeChanged: cubit.updateTime,
                            onTypeChanged: cubit.updateType,
                            onApply: cubit.applyFilters,
                            onClear: cubit.clearFilters,
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<DriverRidesCubit, DriverRidesState>(
                            builder: (context, driverRideState) {
                              final userState = context
                                  .watch<UserCubit>()
                                  .state;
                              final isDriverMode =
                                  userState.activeRole == UserRole.driver;
                              final hasActiveRide =
                                  isDriverMode &&
                                  driverRideState.status ==
                                      DriverRidesStatus.success;
                              final isCheckingAvailability =
                                  isDriverMode &&
                                  driverRideState.status ==
                                      DriverRidesStatus.loading;

                              return RideOffersListSection(
                                state: state,
                                isReserveEnabled:
                                    !hasActiveRide &&
                                    !isCheckingAvailability &&
                                    !state.isReserving,
                                reservingRideId: state.reservingRideId,
                                onReserve: (index) {
                                  final riderId = userState.user?.rider?.id;
                                  cubit.reserveRide(
                                    offer: state.offers[index],
                                    riderId: riderId,
                                  );
                                },
                                onRetry: cubit.loadRideOffers,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          bottomNavigationBar: navigation_layout.NavigationBar(
            selectedItem: navigation_layout.NavigationBarItem.home,
          ),
        ),
      ),
    );
  }
}
