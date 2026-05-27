import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../auth/presentation/view_model/auth_cubit.dart';
import '../../view_model/user_cubit.dart';
import '../../view_model/user_state.dart';
import 'profile_logout_button.dart';
import 'profile_role_stats_card.dart';
import 'profile_user_header.dart';
import 'user_role_selector.dart';

class ProfileContent extends StatelessWidget {
  final String fullName;
  final String email;

  const ProfileContent({
    required this.fullName,
    required this.email,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        final activeProfile = state.activeProfile;
        final isLoading = state.status == UserStatus.loading;

        return SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Perfil',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.primary.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray50,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.hasMultipleRoles
                            ? 'Selecciona el rol con el que deseas usar la aplicación.'
                            : 'Consulta la información asociada a tu cuenta.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.primary.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate400,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.slate100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.slate200),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadowSoft,
                              blurRadius: 14,
                              offset: Offset(4, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ProfileUserHeader(
                              fullName: fullName,
                              email: email,
                            ),
                            const SizedBox(height: 24),
                            UserRoleSelector(
                              availableRoles: state.availableRoles,
                              activeRole: state.activeRole,
                              onChanged: (role) {
                                context.read<UserCubit>().changeRole(role);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isLoading)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.amber700,
                              ),
                            ),
                          ),
                        )
                      else
                        ProfileRoleStatsCard(
                          cancellationOdds: activeProfile?.cancellationOdds,
                          rating: activeProfile?.rating,
                          errorMessage:
                              state.status == UserStatus.error ? state.errorMessage : null,
                          isShowingCachedData: state.hasCachedDataWarning,
                          onRetry: () {
                            context.read<UserCubit>().loadProfiles();
                          },
                        ),
                      const SizedBox(height: 24),
                      ProfileLogoutButton(
                        onPressed: () {
                          context.read<AuthCubit>().logout();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
