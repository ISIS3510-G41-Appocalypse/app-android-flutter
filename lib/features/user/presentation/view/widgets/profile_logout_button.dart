import 'package:flutter/material.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_colors.dart';

class ProfileLogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ProfileLogoutButton({
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amber700,
          foregroundColor: AppColors.gray50,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          'Cerrar sesion',
          style: AppTextStyles.secondary.copyWith(
            color: AppColors.gray50,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
