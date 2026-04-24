import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/verify_session.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUser loginUser;
  final LogoutUser logoutUser;
  final VerifySession verifySessionUseCase;

  AuthCubit({
    required this.loginUser,
    required this.logoutUser,
    required this.verifySessionUseCase,
  }) : super(const AuthState(status: AuthStatus.unauthenticated));

  Future<void> verifySession() async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await verifySessionUseCase();
    result.fold(
      (failure) {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          clearAuth: true,
          errorMessage: failure.message,
        ));
      },
      (auth) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          auth: auth,
          clearError: true,
        ));
      },
    );
  }

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
            clearAuth: true,
          ),
        );
      },
      (auth) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            auth: auth,
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
            clearAuth: true,
            clearError: true,
          ),
        );
      },
    );
  }

  bool get isAuthenticated =>
      state.status == AuthStatus.authenticated && state.auth != null;

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
