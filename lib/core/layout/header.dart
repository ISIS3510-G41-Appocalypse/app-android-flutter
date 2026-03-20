import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.blue900,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Happy Ride',
        style: TextStyle(color: AppColors.gray50),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(Icons.directions_car_rounded, color: AppColors.amber700),
        ),
      ],
    );
  }
}
