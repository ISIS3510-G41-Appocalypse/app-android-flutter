import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/presentation/view_model/auth_cubit.dart';
import '../../../../auth/presentation/view_model/auth_state.dart';
import '../../view_model/user_cubit.dart';

class UserAuthListener extends StatelessWidget {
  final Widget child;

  const UserAuthListener({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status || previous.auth != current.auth,
      listener: (context, state) {
        final userCubit = context.read<UserCubit>();

        if (state.status == AuthStatus.authenticated && state.auth != null) {
          userCubit.loadUser(state.auth!);
          return;
        }

        if (state.status == AuthStatus.unauthenticated) {
          userCubit.clear();
        }
      },
      child: child,
    );
  }
}
