import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../models/driver_ride_view_data.dart';

class DriverRideCard extends StatelessWidget {
  const DriverRideCard({super.key, required this.ride});

  final DriverRideViewData ride;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ride.title,
            style: AppTextStyles.primary.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 20),
          _RoutePoint(
            label: 'Inicio',
            value: ride.source,
          ),
          const SizedBox(height: 14),
          _RoutePoint(
            label: 'Destino',
            value: ride.destination,
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoBullet(label: 'Estado: ${ride.stateLabel}'),
              const SizedBox(height: 10),
              _InfoBullet(label: ride.departureTimeLabel),
              const SizedBox(height: 10),
              _InfoBullet(label: ride.availableSlotsLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.primary.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.primary.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.slate900,
          ),
        ),
      ],
    );
  }
}

class _InfoBullet extends StatelessWidget {
  const _InfoBullet({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(
            color: AppColors.slate900,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.primary.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }
}
