import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text.rich(
          TextSpan(
            text: 'Muévete fácil dentro de ',
            style: AppTextStyles.primary.copyWith(
              color: AppColors.gray50,
              fontWeight: FontWeight.bold,
              fontSize: 32,
              height: 1.2,
            ),
            children: const [
              TextSpan(
                text: 'Uniandes',
                style: TextStyle(
                  color: AppColors.amber700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          'Somos una comunidad uniandina que facilita compartir rides entre estudiantes, profesores y administrativos.',
          textAlign: TextAlign.center,
          style: AppTextStyles.secondary.copyWith(
            color: AppColors.slate400,
            fontWeight: FontWeight.w300,
            fontSize: 18,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '"Your ride. No stress."',
          textAlign: TextAlign.center,
          style: AppTextStyles.secondary.copyWith(
            color: Colors.white70,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w300,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}