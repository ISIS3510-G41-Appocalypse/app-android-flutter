import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'profile_metric_item.dart';

class ProfileRoleStatsCard extends StatelessWidget {
  final double? cancellationOdds;
  final double? rating;
  final String? errorMessage;

  const ProfileRoleStatsCard({
    required this.cancellationOdds,
    required this.rating,
    required this.errorMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 14,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mi desempeño',
            textAlign: TextAlign.center,
            style: AppTextStyles.secondary.copyWith(
              color: AppColors.slate900,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (errorMessage != null)
            Text(
              errorMessage!,
              style: AppTextStyles.secondary.copyWith(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            )
          else
            Row(
              children: [
                Expanded(
                  child: ProfileMetricItem(
                    icon: Icons.star_rounded,
                    iconColor: AppColors.gold500,
                    label: 'Calificacion',
                    value: rating?.toStringAsFixed(1) ?? '--',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ProfileMetricItem(
                    icon: Icons.event_busy_rounded,
                    iconColor: AppColors.rose600,
                    label: 'Cancelacion',
                    value: cancellationOdds == null
                        ? '--'
                        : '${(cancellationOdds! * 100).toStringAsFixed(0)}%',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
