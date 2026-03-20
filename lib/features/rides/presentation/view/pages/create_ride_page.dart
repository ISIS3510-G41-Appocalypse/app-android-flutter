import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../auth/presentation/view_model/auth_cubit.dart';
import '../../view_model/create_ride_cubit.dart';
import '../widgets/create_ride_form.dart';

class CreateRidePage extends StatelessWidget {
  const CreateRidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateRideCubit(
        client: context.read<DioClient>(),
        userId: context.read<AuthCubit>().currentUserId!,
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
      ),
    );
  }
}