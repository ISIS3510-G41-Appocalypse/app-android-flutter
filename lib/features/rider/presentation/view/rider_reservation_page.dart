import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/layout/header.dart' as header_layout;
import '../../../../../core/layout/navigation_bar.dart' as navigation_layout;
import '../../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/view_model/auth_cubit.dart';
import '../viewmodel/reservation_cubit.dart';
import '../widgets/reservation_card.dart';

class RiderReservationPage extends StatefulWidget {
  const RiderReservationPage({super.key});

  @override
  State<RiderReservationPage> createState() => _RiderReservationPageState();
}

class _RiderReservationPageState extends State<RiderReservationPage> {
  final GetIt _sl = GetIt.instance;
  late final ReservationCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = _sl<ReservationCubit>();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.slate900,
        appBar: const header_layout.Header(),
        body: Builder(
          builder: (context) {
            if (user == null || user.riderId == null) {
              return const Center(child: Text('No hay usuario autenticado'));
            }
            return BlocBuilder<ReservationCubit, ReservationState>(
              builder: (context, state) {
                if (state is ReservationInitial) {
                  context.read<ReservationCubit>().fetchActiveReservation(user.riderId!);
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ReservationLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ReservationLoaded) {
                  return ReservationCard(reservation: state.reservation);
                } else if (state is ReservationEmpty) {
                  return const Center(child: Text('No tienes viaje activo'));
                } else if (state is ReservationError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
        bottomNavigationBar: const navigation_layout.NavigationBar(
          selectedItem: navigation_layout.NavigationBarItem.rides,
        ),
      ),
    );
  }
}
