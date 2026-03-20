import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'routes.dart';
import '../core/network/dio_client.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/data/datasources/auth_remote_datasource_impl.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/usecases/login_user.dart';
import '../features/auth/domain/usecases/logout_user.dart';
import '../features/auth/presentation/view_model/auth_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Happy Ride',
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      builder: (context, child) {
        final tokenStorage = TokenStorage();
        final dioClient = DioClient(tokenStorage: tokenStorage);
        final authRemoteDataSource = AuthRemoteDataSourceImpl(
          dio: dioClient.dio,
          tokenStorage: tokenStorage,
        );
        final authRepository = AuthRepositoryImpl(
          remoteDataSource: authRemoteDataSource,
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
          child: child!,
        );
      },
    );
  }
}