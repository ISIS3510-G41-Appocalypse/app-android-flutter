import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/dio_client.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/data/datasources/auth_datasource_remote_supabase.dart';
import '../features/auth/data/repositories/auth_repository_remote.dart';
import '../features/auth/domain/usecases/login_user.dart';
import '../features/auth/domain/usecases/logout_user.dart';
import '../features/auth/presentation/view_model/auth_cubit.dart';

class AuthDependencies extends StatelessWidget {
  final Widget child;
  const AuthDependencies({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final tokenStorage = TokenStorage();
    final dioClient = DioClient(tokenStorage: tokenStorage);
    final authRemoteDataSource = AuthDataSourceRemoteSupabase(
      dio: dioClient.dio,
      tokenStorage: tokenStorage,
    );
    final authRepository = AuthRepositoryRemote(
      dataSourceRemote: authRemoteDataSource,
      tokenStorage: tokenStorage,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(
            loginUser: LoginUser(authRepository),
            logoutUser: LogoutUser(authRepository),
          ),
        ),
      ],
      child: child,
    );
  }
}