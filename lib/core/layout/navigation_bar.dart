import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum NavigationBarItem { home, rides, profile }

class NavigationBar extends StatelessWidget {
  const NavigationBar({
    super.key,
    required this.selectedItem,
    this.onHomeTap,
    this.onRidesTap,
    this.onProfileTap,
  });

  final NavigationBarItem selectedItem;
  final VoidCallback? onHomeTap;
  final VoidCallback? onRidesTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.blue900,
        border: Border(top: BorderSide(color: AppColors.blue900)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _BottomItem(
              icon: Icons.home_rounded,
              label: 'Home',
              selected: selectedItem == NavigationBarItem.home,
              onTap: onHomeTap,
            ),
            _BottomItem(
              icon: Icons.directions_car_outlined,
              label: 'Viajes',
              selected: selectedItem == NavigationBarItem.rides,
              onTap: onRidesTap,
            ),
            _BottomItem(
              icon: Icons.person_outline_rounded,
              label: 'Perfil',
              selected: selectedItem == NavigationBarItem.profile,
              onTap: onProfileTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.amber700 : AppColors.gray50;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
