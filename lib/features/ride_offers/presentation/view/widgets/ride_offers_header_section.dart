import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../app/routes.dart';

class RideOffersHeaderSection extends StatelessWidget {
  const RideOffersHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.createRide);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.amber700,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'Publicar viaje',
            style: AppTextStyles.primary.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Oferta de viajes',
          textAlign: TextAlign.center,
          style: AppTextStyles.primary.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.gray50,
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
