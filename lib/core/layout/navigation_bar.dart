import 'package:flutter/material.dart';

import '../../app/routes.dart';
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

  void _handleTap(BuildContext context, NavigationBarItem item) {
    final customHandler = switch (item) {
      NavigationBarItem.home => onHomeTap,
      NavigationBarItem.rides => onRidesTap,
      NavigationBarItem.profile => onProfileTap,
    };

    if (customHandler != null) {
      customHandler();
      return;
    }

    switch (item) {
      case NavigationBarItem.home:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.rideOffers,
          (route) => false,
        );
        break;
      case NavigationBarItem.rides:
        Navigator.pushNamed(context, AppRoutes.riderReservation,
        );
        break;
      case NavigationBarItem.profile:
        Navigator.pushNamed(context, AppRoutes.profile);
        break;
    }
  }

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
              onTap: () => _handleTap(context, NavigationBarItem.home),
            ),
            _BottomItem(
              icon: Icons.directions_car_outlined,
              label: 'Viajes',
              selected: selectedItem == NavigationBarItem.rides,
              onTap: () => _handleTap(context, NavigationBarItem.rides),
            ),
            _BottomItem(
              icon: Icons.person_outline_rounded,
              label: 'Perfil',
              selected: selectedItem == NavigationBarItem.profile,
              onTap: () => _handleTap(context, NavigationBarItem.profile),
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
