import 'package:flutter/material.dart';

import '../../../../../app/routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class NoDriverPermissionState extends StatelessWidget {
  const NoDriverPermissionState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 40,
              color: AppColors.blue900,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin permisos para crear viajes',
              textAlign: TextAlign.center,
              style: AppTextStyles.primary.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tu cuenta no tiene un perfil de conductor activo, por eso no puedes publicar viajes en este momento.',
              textAlign: TextAlign.center,
              style: AppTextStyles.primary.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.rideOffers,
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Volver a ofertas',
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
      ),
    );
  }
}
