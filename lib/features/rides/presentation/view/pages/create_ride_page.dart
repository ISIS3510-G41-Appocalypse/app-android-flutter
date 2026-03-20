import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/storage/token_storage.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../view_model/create_ride_view_model.dart';
import '../widgets/create_ride_form.dart';

class CreateRidePage extends StatelessWidget {
  const CreateRidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateRideViewModel(
        client:       context.read<DioClient>(),
        tokenStorage: context.read<TokenStorage>(),
      )..loadVehicles(),
      child: Scaffold(
        backgroundColor: AppColors.slate900,

        appBar: AppBar(
          backgroundColor: AppColors.slate900,
          elevation:       0,
          centerTitle:     true,
          title: Text(
            'Happy Ride',
            style: AppTextStyles.primary.copyWith(
              color:      AppColors.amber700,
              fontSize:   18,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.directions_car_rounded,
                  color: AppColors.amber700),
            ),
          ],
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'Ofertar viaje',
                      style: AppTextStyles.primary.copyWith(
                        color:      Colors.white,
                        fontSize:   24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Completa los detalles para compartir tu ruta.',
                      style: AppTextStyles.primary.copyWith(
                        color:    AppColors.slate400,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Container(
                width:   double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:      Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset:     const Offset(5, 5),
                    ),
                  ],
                ),
                child: const CreateRideForm(),
              ),
            ],
          ),
        ),

        bottomNavigationBar: _BottomNav(),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.slate900,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.local_offer_outlined,   label: 'Ofertas'),
              _NavItem(icon: Icons.directions_car_rounded, label: 'Viajes',
                  isActive: true),
              _NavItem(icon: Icons.forum_outlined,         label: 'Chat'),
              _NavItem(icon: Icons.person_outline_rounded, label: 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     isActive;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
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