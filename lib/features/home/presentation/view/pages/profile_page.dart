import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/layout/header.dart';
import '../../../../../core/layout/navigation_bar.dart' as navigation_layout;
import '../../../../auth/presentation/view_model/auth_cubit.dart';
import '../../../../auth/presentation/view_model/auth_state.dart';
import '../../../../auth/presentation/view/widgets/auth_session_listener.dart';
import '../../../../../core/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthSessionListener(
      child: Scaffold(
        backgroundColor: AppColors.slate900,
        appBar: const Header(),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final user = state.user;

            if (state.status == AuthStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (user == null) {
              return const Center(
                child: Text('No hay usuario autenticado', style: TextStyle(color: AppColors.gray50)),
              );
            }

            return Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.account_circle_rounded, size: 64, color: AppColors.amber700),
                    const SizedBox(height: 18),
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: const TextStyle(
                        color: AppColors.slate900,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email,
                      style: const TextStyle(
                        color: AppColors.slate800,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.amber700,
                          foregroundColor: AppColors.gray50,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          context.read<AuthCubit>().logout();
                        },
                        child: const Text('Cerrar sesión'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: const navigation_layout.NavigationBar(
          selectedItem: navigation_layout.NavigationBarItem.profile,
        ),
      ),
    );
  }
}
