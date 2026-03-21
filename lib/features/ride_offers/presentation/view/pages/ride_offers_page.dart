import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/layout/header.dart' as header_layout;
import '../../../../../core/layout/navigation_bar.dart' as navigation_layout;
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/view_model/auth_cubit.dart';
import '../../../../auth/presentation/view/widgets/auth_session_listener.dart';
import '../../../../driver_rides/presentation/view_model/driver_rides_cubit.dart';
import '../../../../driver_rides/presentation/view_model/driver_rides_state.dart';
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

    final user = context.read<AuthCubit>().state.user;
    final preferredZoneId = user?.zoneId.toString();

    _cubit = _sl<RideOffersCubit>()
      ..loadInitialData(preferredZoneId: preferredZoneId);
    _driverRidesCubit = _sl<DriverRidesCubit>()
      ..loadActiveRide(driverId: user?.driverId);
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
            child: BlocBuilder<RideOffersCubit, RideOffersState>(
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
                        BlocBuilder<DriverRidesCubit, DriverRidesState>(
                          builder: (context, driverRideState) {
                            final hasActiveRide =
                                driverRideState.status ==
                                DriverRidesStatus.success;
                            final isCheckingAvailability =
                                driverRideState.status ==
                                DriverRidesStatus.loading;

                            return RideOffersHeaderSection(
                              isPublishEnabled:
                                  !hasActiveRide && !isCheckingAvailability,
                              helperText: isCheckingAvailability
                                  ? 'Verificando si ya tienes un viaje activo...'
                                  : hasActiveRide
                                  ? 'Ya tienes un viaje publicado. Debes iniciarlo o cancelarlo para publicar otro.'
                                  : null,
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
                            final hasActiveRide =
                                driverRideState.status ==
                                DriverRidesStatus.success;
                            final isCheckingAvailability =
                                driverRideState.status ==
                                DriverRidesStatus.loading;

                            return RideOffersListSection(
                              state: state,
                              isReserveEnabled:
                                  !hasActiveRide && !isCheckingAvailability,
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
          bottomNavigationBar: navigation_layout.NavigationBar(
            selectedItem: navigation_layout.NavigationBarItem.home,
          ),
        ),
      ),
    );
  }
}
