import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../features/auth/presentation/view_model/auth_cubit.dart';

final sl = GetIt.instance;

class AppDependencies extends StatelessWidget {
  final Widget child;
  const AppDependencies({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
      ],
      child: child,
    );
  }
}