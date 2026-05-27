import 'package:flutter/material.dart';

import '../../../../../core/widgets/offline_state_card.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'profile_metric_item.dart';

class ProfileRoleStatsCard extends StatelessWidget {
  final double? cancellationOdds;
  final double? rating;
  final String? errorMessage;
  final bool isShowingCachedData;
  final VoidCallback onRetry;

  const ProfileRoleStatsCard({
    required this.cancellationOdds,
    required this.rating,
    required this.errorMessage,
    required this.isShowingCachedData,
    required this.onRetry,
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
            OfflineStateCard(
              title: 'Sin conexión',
              message:
                  'No pudimos actualizar tu desempeño en este momento. Puedes seguir usando la última información disponible e intentarlo de nuevo cuando vuelva la conexión.',
              onRetry: onRetry,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ProfileMetricItem(
                        icon: Icons.star_rounded,
                        iconColor: AppColors.gold500,
                        label: 'Calificación',
                        value: rating?.toStringAsFixed(1) ?? '--',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ProfileMetricItem(
                        icon: Icons.event_busy_rounded,
                        iconColor: AppColors.rose600,
                        label: 'Cancelación',
                        value: cancellationOdds == null
                            ? '--'
                            : '${(cancellationOdds! * 100).toStringAsFixed(0)}%',
                      ),
                    ),
                  ],
                ),
                if (isShowingCachedData) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.slate200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Esta información puede no estar actualizada. Apenas tengas internet, si hubo cambios, se actualizara.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.primary.copyWith(
                        color: AppColors.slate900,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
