import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../view_model/ride_map_cubit.dart';
import '../../view_model/ride_map_state.dart';

class RiderLocationSharingCard extends StatefulWidget {
  const RiderLocationSharingCard({
    super.key,
    required this.rideId,
    required this.userId,
  });

  final String rideId;
  final int? userId;

  @override
  State<RiderLocationSharingCard> createState() =>
      _RiderLocationSharingCardState();
}

class _RiderLocationSharingCardState extends State<RiderLocationSharingCard> {
  late final RideMapCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.instance<RideMapCubit>();
    _share();
  }

  @override
  void didUpdateWidget(covariant RiderLocationSharingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rideId != widget.rideId ||
        oldWidget.userId != widget.userId) {
      _share();
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _share() {
    _cubit.shareCurrentUserLocation(
      rideId: widget.rideId,
      userId: widget.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<RideMapCubit, RideMapState>(
        builder: (context, state) {
          final isLoading = state.status == RideMapStatus.loading;
          final color = state.isOffline
              ? const Color(0xFF92400E)
              : state.isPermissionBlocked
              ? const Color(0xFFDC2626)
              : AppColors.blue900;

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.amber700,
                    ),
                  )
                else
                  Icon(Icons.location_on_rounded, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isLoading
                        ? 'Compartiendo tu ubicacion del viaje...'
                        : state.message ??
                              'Tu ubicacion se comparte con el conductor mientras el viaje esta en curso.',
                    style: AppTextStyles.primary.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Actualizar ubicacion',
                  onPressed: isLoading ? null : _share,
                  icon: const Icon(Icons.refresh_rounded),
                  color: AppColors.blue900,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
