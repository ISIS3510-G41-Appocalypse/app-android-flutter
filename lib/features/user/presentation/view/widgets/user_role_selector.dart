import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/user_role.dart';

class UserRoleSelector extends StatelessWidget {
  final List<UserRole> availableRoles;
  final UserRole? activeRole;
  final ValueChanged<UserRole> onChanged;

  const UserRoleSelector({
    required this.availableRoles,
    required this.activeRole,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (availableRoles.isEmpty) {
      return const SizedBox.shrink();
    }

    if (availableRoles.length == 1) {
      return _RoleCard(
        role: availableRoles.first,
        isSelected: true,
        onTap: null,
      );
    }

    return Row(
      children: availableRoles.map((role) {
        final isSelected = role == activeRole;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: role == availableRoles.last ? 0 : 12,
            ),
            child: _RoleCard(
              role: role,
              isSelected: isSelected,
              onTap: () => onChanged(role),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _labelForRole(UserRole role) {
    switch (role) {
      case UserRole.rider:
        return 'Pasajero';
      case UserRole.driver:
        return 'Conductor';
    }
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback? onTap;

  const _RoleCard({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = switch (role) {
      UserRole.rider => 'Pasajero',
      UserRole.driver => 'Conductor',
    };
    final icon = switch (role) {
      UserRole.rider => Icons.hail_rounded,
      UserRole.driver => Icons.directions_car_rounded,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.amber700
              : AppColors.amber700.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.amber700
                : AppColors.amber700.withValues(alpha: 0.22),
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppColors.shadowSelected,
                    blurRadius: 10,
                    offset: Offset(2, 2),
                  ),
                ]
              : const [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.white : AppColors.amber700,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.secondary.copyWith(
                color: isSelected ? AppColors.white : AppColors.slate900,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
