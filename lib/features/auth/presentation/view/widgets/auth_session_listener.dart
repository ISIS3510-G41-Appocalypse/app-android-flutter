import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../app/routes.dart';
import '../../../../auth/presentation/view_model/auth_cubit.dart';
import '../../../../auth/presentation/view_model/auth_state.dart';

class AuthSessionListener extends StatelessWidget {
  final Widget child;
  const AuthSessionListener({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          );
        }
        if (state.status == AuthStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: child,
    );
  }
}