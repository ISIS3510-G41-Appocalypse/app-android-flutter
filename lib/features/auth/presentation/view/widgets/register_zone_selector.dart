import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../ride_offers/domain/entities/zone.dart';

class RegisterZoneSelector extends StatelessWidget {
  const RegisterZoneSelector({
    super.key,
    required this.zones,
    required this.selectedZoneId,
    required this.onSelected,
    this.errorText,
    this.isLoading = false,
  });

  final List<Zone> zones;
  final String? selectedZoneId;
  final ValueChanged<String?> onSelected;
  final String? errorText;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zona preferida',
          style: AppTextStyles.secondary.copyWith(
            color: AppColors.slate800,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedZoneId,
          autovalidateMode: AutovalidateMode.disabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            hintText: isLoading ? 'Cargando zonas...' : 'Selecciona una zona',
            hintStyle: const TextStyle(color: AppColors.slate400),
            prefixIcon: const Icon(Icons.place_outlined, color: AppColors.slate400),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 16,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(
                color: AppColors.slate400,
                width: 1.5,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(
                color: AppColors.slate400,
                width: 1.5,
              ),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(
                color: AppColors.errorRed,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(
                color: AppColors.errorRed,
                width: 1.5,
              ),
            ),
            errorText: errorText,
            errorMaxLines: 2,
          ),
          items: zones
              .map(
                (zone) => DropdownMenuItem<String>(
                  value: zone.id,
                  child: Text(
                    zone.name,
                    style: AppTextStyles.primary.copyWith(
                      color: AppColors.slate900,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: isLoading ? null : onSelected,
        ),
      ],
    );
  }
}
