import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class ProfileUserHeader extends StatelessWidget {
  final String fullName;
  final String email;

  const ProfileUserHeader({
    required this.fullName,
    required this.email,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.amber700,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.amber700),
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 30,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          fullName,
          style: AppTextStyles.secondary.copyWith(
            color: AppColors.slate900,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          email,
          style: AppTextStyles.primary.copyWith(
            color: AppColors.slate800,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
