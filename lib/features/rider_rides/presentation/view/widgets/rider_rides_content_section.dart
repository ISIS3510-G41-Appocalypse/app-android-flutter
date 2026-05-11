import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/offline_state_card.dart';
import '../../../../ride_map/presentation/view/widgets/ride_map_panel.dart';
import '../../../../user/presentation/view_model/user_cubit.dart';
import '../../view_model/rider_rides_cubit.dart';
import '../../view_model/rider_rides_state.dart';
import '../models/rider_ride_view_data.dart';
import 'rider_ride_card.dart';

class RiderRidesContentSection extends StatelessWidget {
  const RiderRidesContentSection({super.key, required this.state});

  final RiderRidesState state;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case RiderRidesStatus.initial:
      case RiderRidesStatus.loading:
        return const _StateCard(
          child: Column(
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.amber700,
                ),
              ),
              SizedBox(height: 16),
              Text('Cargando tu reserva...', textAlign: TextAlign.center),
            ],
          ),
        );
      case RiderRidesStatus.empty:
        return _StateCard(
          child: Text(
            state.message ?? 'Aun no tienes una reserva activa.',
            textAlign: TextAlign.center,
          ),
        );
      case RiderRidesStatus.error:
        if (state.isOffline) {
          return OfflineStateCard(
            title: 'Sin conexion',
            message:
                'No pudimos cargar tu reserva. Revisa tu conexion e intenta de nuevo.',
            onRetry: () {
              context.read<RiderRidesCubit>().reloadActiveRide();
            },
          );
        }

        return _StateCard(
          child: Column(
            children: [
              Text(
                state.message ?? 'Ocurrio un error al cargar tu reserva.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.read<RiderRidesCubit>().reloadActiveRide();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.blue900,
                    side: const BorderSide(color: AppColors.blue900),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Reintentar',
                    style: AppTextStyles.primary.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case RiderRidesStatus.success:
        final ride = RiderRideViewData.fromEntity(state.ride!);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RiderRideCard(ride: ride),
            if (state.ride!.state == 'EN_CURSO') ...[
              const SizedBox(height: 24),
              RiderRideMapPanel(
                ride: state.ride!,
                user: context.read<UserCubit>().state.user,
              ),
            ],
          ],
        );
    }
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: DefaultTextStyle(
        style: AppTextStyles.primary.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF64748B),
        ),
        child: child,
      ),
    );
  }
}
