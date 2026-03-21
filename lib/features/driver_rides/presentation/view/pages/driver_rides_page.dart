import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../core/layout/header.dart' as header_layout;
import '../../../../../core/layout/navigation_bar.dart' as navigation_layout;
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/view_model/auth_cubit.dart';
import '../../../../auth/presentation/view/widgets/auth_session_listener.dart';
import '../../view_model/driver_rides_cubit.dart';
import '../../view_model/driver_rides_state.dart';
import '../widgets/driver_rides_content_section.dart';
import '../widgets/driver_rides_header_section.dart';

class DriverRidesPage extends StatefulWidget {
  const DriverRidesPage({super.key});

  @override
  State<DriverRidesPage> createState() => _DriverRidesPageState();
}

class _DriverRidesPageState extends State<DriverRidesPage> {
  final GetIt _sl = GetIt.instance;
  late final DriverRidesCubit _cubit;

  @override
  void initState() {
    super.initState();

    final driverId = context.read<AuthCubit>().state.user?.driverId;

    _cubit = _sl<DriverRidesCubit>()..loadActiveRide(driverId: driverId);
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
            child: BlocBuilder<DriverRidesCubit, DriverRidesState>(
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
                        const DriverRidesHeaderSection(),
                        const SizedBox(height: 24),
                        DriverRidesContentSection(state: state),
                      ],
                    ),
                  ),
                );
              },
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
