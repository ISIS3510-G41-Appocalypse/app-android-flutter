import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class RegisterRoleSelector extends StatelessWidget {
  const RegisterRoleSelector({
    super.key,
    required this.wantsDriverRole,
    required this.onDriverRoleChanged,
  });

  final bool wantsDriverRole;
  final ValueChanged<bool> onDriverRoleChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RoleOptionCard(
          title: 'Pasajero',
          subtitle: 'Encuentra wheels disponibles',
          icon: Icons.location_on_rounded,
          isSelected: true,
          onTap: () => onDriverRoleChanged(false),
        ),
        const SizedBox(height: 12),
        _RoleOptionCard(
          title: 'Conductor',
          subtitle: 'Ofrece wheels a otras personas',
          icon: Icons.directions_car_rounded,
          isSelected: wantsDriverRole,
          onTap: () => onDriverRoleChanged(!wantsDriverRole),
        ),
      ],
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  const _RoleOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7ED) : AppColors.slate50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.amber700 : AppColors.slate200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.amber700 : AppColors.slate100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.white : AppColors.slate400,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.secondary.copyWith(
                      color: AppColors.slate900,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.primary.copyWith(
                      color: AppColors.slate400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.amber700 : AppColors.slate300,
            ),
          ],
        ),
      ),
    );
  }
}
