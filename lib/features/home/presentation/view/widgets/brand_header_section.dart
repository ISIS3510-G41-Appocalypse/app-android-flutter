import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class BrandHeaderSection extends StatelessWidget {
  const BrandHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: AppColors.amber700.withAlpha((0.10 * 255).toInt()),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.directions_car,
            color: AppColors.amber700,
            size: 46,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Happy Ride',
          textAlign: TextAlign.center,
          style: AppTextStyles.primary.copyWith(
            color: AppColors.gray50,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'COMUNIDAD UNIANDINA',
          textAlign: TextAlign.center,
          style: AppTextStyles.secondary.copyWith(
            color: AppColors.amber700,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}