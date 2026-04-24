import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/layout/header.dart';
import '../../../../../core/layout/navigation_bar.dart' as navigation_layout;
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/view_model/auth_cubit.dart';
import '../../../../auth/presentation/view_model/auth_state.dart';
import '../../../../auth/presentation/view/widgets/auth_session_listener.dart';
import '../widgets/profile_content.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthSessionListener(
      child: Scaffold(
        backgroundColor: AppColors.slate900,
        appBar: const Header(),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            final user = authState.user;

            if (authState.status == AuthStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (user == null) {
              return const Center(
                child: Text(
                  'No hay usuario autenticado',
                  style: TextStyle(color: AppColors.gray50),
                ),
              );
            }

            return ProfileContent(
              fullName: '${user.firstName} ${user.lastName}',
              email: user.email,
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
