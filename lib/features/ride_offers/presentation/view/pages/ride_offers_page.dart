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
import '../../../../rider_rides/presentation/view_model/rider_rides_cubit.dart';
import '../../../../rider_rides/presentation/view_model/rider_rides_state.dart';
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
  late final RiderRidesCubit _riderRidesCubit;

  @override
  void initState() {
    super.initState();

    final userState = context.read<UserCubit>().state;
    final user = userState.user;
    final preferredZoneId = user?.zoneId.toString();

    _cubit = _sl<RideOffersCubit>()
      ..loadInitialData(preferredZoneId: preferredZoneId);
    _driverRidesCubit = _sl<DriverRidesCubit>()
      ..loadActiveRide(driverId: user?.driver?.id);
    _riderRidesCubit = _sl<RiderRidesCubit>()
      ..loadActiveRide(riderId: user?.rider?.id);
  }

  @override
  void dispose() {
    _cubit.close();
    _driverRidesCubit.close();
    _riderRidesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _driverRidesCubit),
        BlocProvider.value(value: _riderRidesCubit),
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
                _cubit.syncDefaultFilters(
                  preferredZoneId: userState.user?.zoneId.toString(),
                );
                _driverRidesCubit.loadActiveRide(
                  driverId: userState.user?.driver?.id,
                );
                _riderRidesCubit.loadActiveRide(
                  riderId: userState.user?.rider?.id,
                );
              },
              child: BlocListener<DriverRidesCubit, DriverRidesState>(
                listenWhen: (previous, current) =>
                    previous.ride?.id != current.ride?.id,
                listener: (context, driverRideState) {
                  _cubit.updateExcludedRideId(driverRideState.ride?.id);
                },
                child: BlocConsumer<RideOffersCubit, RideOffersState>(
                  listenWhen: (previous, current) =>
                      !previous.reservationCreated &&
                      current.reservationCreated,
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
                                    return BlocBuilder<
                                      RiderRidesCubit,
                                      RiderRidesState
                                    >(
                                      builder: (context, riderRideState) {
                                        final hasActiveDriverRide =
                                            driverRideState.status ==
                                            DriverRidesStatus.success;
                                        final hasActiveRiderReservation =
                                            riderRideState.status ==
                                            RiderRidesStatus.success;
                                        final isCheckingAvailability =
                                            driverRideState.status ==
                                                DriverRidesStatus.loading ||
                                            riderRideState.status ==
                                                RiderRidesStatus.loading;
                                        String? helperText;

                                        if (isCheckingAvailability) {
                                          helperText =
                                              'Verificando si ya tienes un viaje o una reserva activa...';
                                        } else if (hasActiveDriverRide) {
                                          helperText =
                                              'Ya tienes un viaje activo como conductor. Debes cancelarlo o finalizarlo antes de publicar otro.';
                                        } else if (hasActiveRiderReservation) {
                                          helperText =
                                              'Debes cancelar o finalizar tu reserva activa antes de publicar un viaje.';
                                        }

                                        return RideOffersHeaderSection(
                                          showPublishAction: isDriverMode,
                                          isPublishEnabled:
                                              !hasActiveDriverRide &&
                                              !hasActiveRiderReservation &&
                                              !isCheckingAvailability,
                                          helperText: helperText,
                                        );
                                      },
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
                                return BlocBuilder<
                                  RiderRidesCubit,
                                  RiderRidesState
                                >(
                                  builder: (context, riderRideState) {
                                    final driverRidesCubit = context.read<
                                      DriverRidesCubit
                                    >();
                                    final riderRidesCubit = context.read<
                                      RiderRidesCubit
                                    >();
                                    final hasActiveDriverRide =
                                        driverRideState.status ==
                                        DriverRidesStatus.success;
                                    final isCheckingDriverRide =
                                        driverRideState.status ==
                                        DriverRidesStatus.loading;
                                    final reserveDisabledReason =
                                        isCheckingDriverRide
                                        ? 'Verificando si ya tienes un viaje activo como conductor...'
                                        : hasActiveDriverRide
                                        ? 'Debes cancelar o finalizar tu viaje activo como conductor antes de reservar otro viaje.'
                                        : null;

                                    return RideOffersListSection(
                                      state: state,
                                      isReserveEnabled:
                                          !hasActiveDriverRide &&
                                          !isCheckingDriverRide &&
                                          !state.isReserving,
                                      reserveDisabledReason:
                                          reserveDisabledReason,
                                      currentDriverId: userState.user?.driver?.id
                                          .toString(),
                                      reservingRideId: state.reservingRideId,
                                      onReserve: (index) {
                                        final riderId =
                                            userState.user?.rider?.id;
                                        cubit.reserveRide(
                                          offer: state.offers[index],
                                          riderId: riderId,
                                          currentDriverId: userState.user?.driver
                                              ?.id
                                              .toString(),
                                          hasActiveDriverRide:
                                              hasActiveDriverRide,
                                        );
                                      },
                                      onRetry: () async {
                                        await cubit.loadRideOffers();
                                        await driverRidesCubit.reloadActiveRide();
                                        await riderRidesCubit.reloadActiveRide();
                                      },
                                    );
                                  },
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
          ),
          bottomNavigationBar: navigation_layout.NavigationBar(
            selectedItem: navigation_layout.NavigationBarItem.home,
          ),
        ),
      ),
    );
  }
}
