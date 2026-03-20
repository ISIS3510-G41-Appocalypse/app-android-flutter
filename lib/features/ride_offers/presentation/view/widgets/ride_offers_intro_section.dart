import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';


class RideOffersIntroSection extends StatelessWidget {
  const RideOffersIntroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Oferta de viajes',
          textAlign: TextAlign.center,
          style: AppTextStyles.primary.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.slate900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Encuentra el viaje perfecto para tu trayecto uniandino.',
          textAlign: TextAlign.center,
          style: AppTextStyles.primary.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}