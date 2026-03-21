import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../view_model/driver_rides_cubit.dart';
import '../../view_model/driver_rides_state.dart';
import '../models/driver_ride_view_data.dart';
import 'driver_ride_card.dart';

class DriverRidesContentSection extends StatelessWidget {
  const DriverRidesContentSection({super.key, required this.state});

  final DriverRidesState state;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case DriverRidesStatus.initial:
      case DriverRidesStatus.loading:
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
              Text(
                'Cargando tu viaje como conductor...',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      case DriverRidesStatus.empty:
        return _StateCard(
          child: Column(
            children: [
              Text(
                state.message ?? 'Aun no tienes un viaje publicado',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.createRide);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.amber700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Publicar viaje',
                    style: AppTextStyles.primary.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case DriverRidesStatus.error:
        return _StateCard(
          child: Column(
            children: [
              Text(
                state.message ?? 'Ocurrio un error al cargar tu viaje.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.read<DriverRidesCubit>().reloadActiveRide();
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
      case DriverRidesStatus.success:
        return DriverRideCard(
          ride: DriverRideViewData.fromEntity(state.ride!),
          onStart: () => context.read<DriverRidesCubit>().startRide(),
          onCancel: () => context.read<DriverRidesCubit>().cancelRide(),
          isUpdating: state.isUpdating,
          updatingAction: state.updatingAction,
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
