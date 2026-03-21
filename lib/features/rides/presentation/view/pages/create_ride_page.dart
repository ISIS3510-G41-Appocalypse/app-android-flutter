import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/layout/header.dart';
import '../../../../../core/layout/navigation_bar.dart' as navigation_layout;
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../auth/presentation/view_model/auth_cubit.dart';
import '../../view_model/create_ride_cubit.dart';
import '../widgets/create_ride_form.dart';

final sl = GetIt.instance;

class CreateRidePage extends StatelessWidget {
  const CreateRidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateRideCubit(
        client: sl<DioClient>(),
        userId: context.read<AuthCubit>().currentUserId!,
      )..loadVehicles(),
      child: Scaffold(
        backgroundColor: AppColors.slate900,
        appBar: const Header(),
        body: SafeArea(
          top: false,
          child: ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(
              overscroll: false,
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Section
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Ofertar viaje',
                          style: AppTextStyles.primary.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Completa los detalles para compartir tu ruta con la comunidad.',
                          style: AppTextStyles.primary.copyWith(
                            color: AppColors.slate400,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Form Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(5, 5),
                        ),
                      ],
                    ),
                    child: const CreateRideForm(),
                  ),
                  const SizedBox(height: 24),
                  // Info Box
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.teal600.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.teal600.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          color: AppColors.teal600,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tu oferta será visible para todos los estudiantes en tu ruta.',
                            style: AppTextStyles.primary.copyWith(
                              fontSize: 12,
                              color: AppColors.teal600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const navigation_layout.NavigationBar(
          selectedItem: navigation_layout.NavigationBarItem.rides,
        ),
      ),
    );
  }
}
