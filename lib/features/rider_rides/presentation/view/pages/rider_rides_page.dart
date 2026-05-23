import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../app/routes.dart';
import '../../../../../core/layout/header.dart' as header_layout;
import '../../../../../core/layout/navigation_bar.dart' as navigation_layout;
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/view/widgets/auth_session_listener.dart';
import '../../../../ratings/presentation/view/pages/ratings_page_args.dart';
import '../../../../user/presentation/view_model/user_cubit.dart';
import '../../../../user/presentation/view_model/user_state.dart';
import '../../view_model/rider_rides_cubit.dart';
import '../../view_model/rider_rides_state.dart';
import '../widgets/rider_rides_content_section.dart';
import '../widgets/rider_rides_header_section.dart';

class RiderRidesPage extends StatefulWidget {
  const RiderRidesPage({super.key});

  @override
  State<RiderRidesPage> createState() => _RiderRidesPageState();
}

class _RiderRidesPageState extends State<RiderRidesPage> {
  final GetIt _sl = GetIt.instance;
  late final RiderRidesCubit _cubit;

  @override
  void initState() {
    super.initState();

    final riderId = context.read<UserCubit>().state.user?.rider?.id;

    _cubit = _sl<RiderRidesCubit>()..loadActiveRide(riderId: riderId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: AuthSessionListener(
        child: Scaffold(
          backgroundColor: AppColors.slate900,
          appBar: const header_layout.Header(),
          body: SafeArea(
            top: false,
            child: BlocListener<UserCubit, UserState>(
              listenWhen: (previous, current) => previous.user != current.user,
              listener: (context, userState) {
                _cubit.loadActiveRide(riderId: userState.user?.rider?.id);
              },
              child: BlocConsumer<RiderRidesCubit, RiderRidesState>(
                listenWhen: (previous, current) {
                  final cancellationFinished =
                      previous.isCancelling &&
                      !current.isCancelling &&
                      current.message != null;
                  final hasRatingPrompt =
                      previous.ratingPrompt != current.ratingPrompt &&
                      current.ratingPrompt != null;

                  return cancellationFinished || hasRatingPrompt;
                },
                listener: (context, state) async {
                  final prompt = state.ratingPrompt;
                  if (prompt != null) {
                    await Navigator.pushNamed(
                      context,
                      AppRoutes.ratings,
                      arguments: RatingsPageArgs.riderRatesDriver(
                        rideId: prompt.rideId,
                        driverId: prompt.driverId,
                        riderId: prompt.riderId,
                        driverName: prompt.driverName,
                      ),
                    );

                    if (!context.mounted) {
                      return;
                    }

                    await context
                        .read<RiderRidesCubit>()
                        .completeRatingPrompt();
                    if (context.mounted) {
                      Navigator.pushNamed(context, AppRoutes.payments);
                    }
                    return;
                  }

                  if (state.message != null) {
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.clearSnackBars();
                    messenger.showSnackBar(
                      SnackBar(content: Text(state.message!)),
                    );
                  }
                },
                builder: (context, state) {
                  return ScrollConfiguration(
                    behavior: const MaterialScrollBehavior().copyWith(
                      overscroll: false,
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const RiderRidesHeaderSection(),
                          const SizedBox(height: 24),
                          RiderRidesContentSection(state: state),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          bottomNavigationBar: const navigation_layout.NavigationBar(
            selectedItem: navigation_layout.NavigationBarItem.rides,
          ),
        ),
      ),
    );
  }
}
