import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../models/driver_ride_view_data.dart';

class DriverRideCard extends StatelessWidget {
  const DriverRideCard({
    super.key,
    required this.ride,
    required this.onStart,
    required this.onCancel,
    required this.onFinish,
    required this.isUpdating,
    required this.updatingAction,
    this.message,
  });

  final DriverRideViewData ride;
  final VoidCallback onStart;
  final VoidCallback onCancel;
  final VoidCallback onFinish;
  final bool isUpdating;
  final String? updatingAction;
  final String? message;

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
          if (ride.showStartedBanner) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Text(
                'Viaje iniciado',
                style: AppTextStyles.primary.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF047857),
                ),
              ),
            ),
          ],
          if (ride.startAvailableFromLabel != null) ...[
            const SizedBox(height: 18),
            _InlineNotice(
              text: ride.startAvailableFromLabel!,
              backgroundColor: const Color(0xFFFFFBEB),
              borderColor: const Color(0xFFFDE68A),
              textColor: const Color(0xFF92400E),
            ),
          ],
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InlineNotice(
              text: message!,
              backgroundColor: const Color(0xFFEFF6FF),
              borderColor: const Color(0xFFBFDBFE),
              textColor: AppColors.blue900,
            ),
          ],
          const SizedBox(height: 22),
          if (ride.state == 'EN_CURSO')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isUpdating ? null : onFinish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal600,
                  disabledBackgroundColor: AppColors.teal600.withValues(
                    alpha: 0.6,
                  ),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  updatingAction == 'finish' && isUpdating
                      ? 'Finalizando...'
                      : 'Finalizar',
                  style: AppTextStyles.primary.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isUpdating || !ride.canStart ? null : onStart,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.blue900,
                      side: const BorderSide(color: AppColors.blue900),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      updatingAction == 'start' && isUpdating
                          ? 'Iniciando...'
                          : 'Iniciar',
                      style: AppTextStyles.primary.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isUpdating ? null : onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      disabledBackgroundColor: const Color(
                        0xFFDC2626,
                      ).withValues(alpha: 0.6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      updatingAction == 'cancel' && isUpdating
                          ? 'Cancelando...'
                          : 'Cancelar',
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
        ],
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({
    required this.text,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  final String text;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: AppTextStyles.primary.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
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
