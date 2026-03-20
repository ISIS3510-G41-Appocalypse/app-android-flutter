import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../auth/presentation/view_model/auth_cubit.dart';
import '../../../../rides/presentation/view/pages/create_ride_page.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.slate900,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.amber700),
        ),
      );
    }

    final List<Widget> pages = [
      const _ComingSoon(label: 'Ofertas'),
      const CreateRidePage(),
      const _ComingSoon(label: 'Chat'),
      const _ComingSoon(label: 'Perfil'),
    ];

    return Scaffold(
      backgroundColor: AppColors.slate900,
      body: pages[_currentIndex],
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  final String label;
  const _ComingSoon({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate900,
      body: Center(
        child: Text(
          label,
          style: AppTextStyles.primary.copyWith(
            color:    AppColors.slate400,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}


class _BottomNav extends StatelessWidget {
  final int               currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.local_offer_outlined,   label: 'Ofertas'),
    _NavItem(icon: Icons.directions_car_rounded, label: 'Viajes'),
    _NavItem(icon: Icons.forum_outlined,         label: 'Chat'),
    _NavItem(icon: Icons.person_outline_rounded, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.slate900,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
              (index) => GestureDetector(
                onTap: () => onTap(index),
                child: _NavItemWidget(
                  icon:     _items[index].icon,
                  label:    _items[index].label,
                  isActive: currentIndex == index,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String   label;
  const _NavItem({required this.icon, required this.label});
}

class _NavItemWidget extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     isActive;

  const _NavItemWidget({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.amber700 : AppColors.slate400;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.primary.copyWith(
            fontSize:      9,
            fontWeight:    FontWeight.w700,
            letterSpacing: 1,
            color:         color,
          ),
        ),
      ],
    );
  }
}