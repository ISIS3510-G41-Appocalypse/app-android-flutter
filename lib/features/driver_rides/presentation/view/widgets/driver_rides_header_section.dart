import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class DriverRidesHeaderSection extends StatelessWidget {
  const DriverRidesHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Mis viajes',
          textAlign: TextAlign.center,
          style: AppTextStyles.primary.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.gray50,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Administra tu viaje activo como conductor desde un solo lugar.',
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
