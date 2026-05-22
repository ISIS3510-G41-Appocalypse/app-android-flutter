import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/performance/performance_features.dart';
import '../../../../core/performance/performance_time_tracker.dart';
import '../../domain/usecases/get_register_zones.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/signup_user.dart';
import '../../domain/usecases/verify_session.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final GetRegisterZones getRegisterZones;
  final SignupUser signupUser;
  final LoginUser loginUser;
  final LogoutUser logoutUser;
  final VerifySession verifySessionUseCase;
  final PerformanceTimeTracker performanceTimeTracker;

  AuthCubit({
    required this.getRegisterZones,
    required this.signupUser,
    required this.loginUser,
    required this.logoutUser,
    required this.verifySessionUseCase,
    required this.performanceTimeTracker,
  }) : super(const AuthState(status: AuthStatus.unauthenticated));

  Future<void> loadRegisterZones() async {
    emit(
      state.copyWith(
        isLoadingRegisterZones: true,
        clearRegisterZonesError: true,
      ),
    );

    final result = await getRegisterZones();
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoadingRegisterZones: false,
            registerZones: const [],
            registerZonesErrorMessage: failure.message,
          ),
        );
      },
      (zones) {
        emit(
          state.copyWith(
            isLoadingRegisterZones: false,
            registerZones: zones,
            clearRegisterZonesError: true,
          ),
        );
      },
    );
  }

  Future<void> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required int zoneId,
    required List<String> roles,
    required List<Map<String, dynamic>> paymentMethods,
    required List<Map<String, dynamic>> vehicles,
  }) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        clearError: true,
      ),
    );

    final result = await signupUser(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      zoneId: zoneId,
      roles: roles,
      paymentMethods: paymentMethods,
      vehicles: vehicles,
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: failure.message,
            clearAuth: true,
          ),
        );
      },
      (_) async {
        await login(
          email: email,
          password: password,
        );
      },
    );
  }

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
    Stopwatch? loginFrontEndStopwatch,
  }) async {
    final stopwatch = loginFrontEndStopwatch ?? (Stopwatch()..start());

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
    stopwatch.stop();

    result.fold(
      (failure) {
        if (failure is NetworkFailure) {
          return;
        }

        unawaited(
          performanceTimeTracker.track(
            feature: PerformanceFeatures.login,
            duration: stopwatch.elapsedMilliseconds.toDouble(),
            source: PerformanceSources.frontEnd,
          ),
        );
      },
      (_) {
        unawaited(
          performanceTimeTracker.track(
            feature: PerformanceFeatures.login,
            duration: stopwatch.elapsedMilliseconds.toDouble(),
            source: PerformanceSources.frontEnd,
          ),
        );
      },
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
