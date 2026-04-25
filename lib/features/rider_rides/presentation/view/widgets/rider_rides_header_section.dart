import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class RiderRidesHeaderSection extends StatelessWidget {
  const RiderRidesHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mis viajes',
          style: AppTextStyles.primary.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.gray50,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Consulta el estado y los detalles de tu reserva activa.',
          style: AppTextStyles.primary.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.slate400,
          ),
        ),
      ],
    );
  }
}
