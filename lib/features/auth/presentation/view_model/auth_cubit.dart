import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUser loginUser;
  final LogoutUser logoutUser;

  AuthCubit({
    required this.loginUser,
    required this.logoutUser,
  }) : super(const AuthState(status: AuthStatus.unauthenticated));

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        clearError: true,
      ),
    );

    final result = await loginUser(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: failure.message,
            clearUser: true,
          ),
        );
      },
      (user) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> logout() async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        clearError: true,
      ),
    );

    final result = await logoutUser();

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            clearUser: true,
            clearError: true,
          ),
        );
      },
    );
  }

  int? get currentUserId => state.user?.id;

  String? get currentUserEmail => state.user?.email;

  bool get isAuthenticated =>
      state.status == AuthStatus.authenticated && state.user != null;
}