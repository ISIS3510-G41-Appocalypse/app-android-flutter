import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/layout/header.dart';
import '../../../../../core/layout/navigation_bar.dart' as navigation_layout;
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/view/widgets/auth_session_listener.dart';
import '../../view_model/user_cubit.dart';
import '../../view_model/user_state.dart';
import '../widgets/profile_content.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthSessionListener(
        child: Scaffold(
          backgroundColor: AppColors.slate900,
          appBar: const Header(),
          body: BlocBuilder<UserCubit, UserState>(
            builder: (context, userState) {
              final user = userState.user;

              if (userState.status == UserStatus.loading && user == null) {
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
