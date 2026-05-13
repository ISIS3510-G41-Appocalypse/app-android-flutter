import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/ride_recommendation.dart';

class RideRecommendationMessage extends StatelessWidget {
  const RideRecommendationMessage({
    super.key,
    required this.recommendation,
  });

  final RideRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final data = _buildData(recommendation.rating);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.slate200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Parece que nunca has viajado con esta persona.',
            style: AppTextStyles.primary.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Con base en las preferencias de tus viajes y en las calificaciones del conductor, creemos que le darias a este viaje este puntaje:',
            style: AppTextStyles.primary.copyWith(
              fontSize: 13,
              color: AppColors.slate400,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: data.backgroundColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: data.borderColor,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    recommendation.rating.toStringAsFixed(2),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.secondary.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: data.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Puntaje estimado',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.primary.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: data.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            data.message,
            style: AppTextStyles.primary.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: data.textColor,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  _RecommendationData _buildData(double rating) {
    if (rating > 4) {
      return const _RecommendationData(
        message: 'Te recomendamos viajar con el.',
        backgroundColor: Color(0xFFE7F7F5),
        borderColor: AppColors.teal600,
        textColor: AppColors.teal600,
      );
    }

    if (rating >= 3) {
      return const _RecommendationData(
        message:
            'Podria ser una buena opcion, pero la decision depende de tu preferencia.',
        backgroundColor: Color(0xFFFFF7E6),
        borderColor: AppColors.gold500,
        textColor: AppColors.amber700,
      );
    }

    return const _RecommendationData(
      message: 'No te recomendamos este viaje.',
      backgroundColor: Color(0xFFFFEEF2),
      borderColor: AppColors.rose600,
      textColor: AppColors.rose600,
    );
  }
}

class _RecommendationData {
  const _RecommendationData({
    required this.message,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  final String message;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
}
