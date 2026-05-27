import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/auth.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_cached_user.dart';
import '../../domain/usecases/load_user.dart';
import '../../domain/usecases/load_profiles.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final GetCachedUser getCachedUserUseCase;
  final LoadUser loadUserUseCase;
  final LoadProfiles loadProfilesUseCase;

  UserCubit({
    required this.getCachedUserUseCase,
    required this.loadUserUseCase,
    required this.loadProfilesUseCase,
  }) : super(const UserState());

  void clear() {
    emit(const UserState());
  }

  Future<void> loadUser(Auth auth) async {
    final cachedUser = getCachedUserUseCase(auth: auth);
    if (cachedUser != null) {
      final cachedRoles = _resolveAvailableRoles(cachedUser);
      final cachedNextRole = cachedRoles.contains(state.activeRole)
          ? state.activeRole
          : _resolveDefaultRole(cachedRoles);

      emit(
        state.copyWith(
          user: cachedUser,
          availableRoles: cachedRoles,
          activeRole: cachedNextRole,
          status: UserStatus.loaded,
          clearError: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: UserStatus.loading,
          clearError: true,
        ),
      );
    }

    final result = await loadUserUseCase(auth: auth);

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: UserStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (user) async {
        final availableRoles = _resolveAvailableRoles(user);
        final nextRole = availableRoles.contains(state.activeRole)
            ? state.activeRole
            : _resolveDefaultRole(availableRoles);

        emit(
          state.copyWith(
            user: user,
            availableRoles: availableRoles,
            activeRole: nextRole,
            status: UserStatus.loaded,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> changeRole(UserRole role) async {
    if (!state.availableRoles.contains(role)) {
      return;
    }

    emit(
      state.copyWith(
        activeRole: role,
        status: UserStatus.loaded,
        clearError: true,
      ),
    );
  }

  Future<void> loadProfiles() async {
    final user = state.user;
    if (user == null) {
      return;
    }

    if (state.status != UserStatus.loaded) {
      emit(
        state.copyWith(
          status: UserStatus.loading,
          clearError: true,
        ),
      );
    }

    final result = await loadProfilesUseCase(currentUser: user);

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: UserStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (updatedUser) async {
        emit(
          state.copyWith(
            user: updatedUser,
            status: UserStatus.loaded,
            clearError: true,
          ),
        );
      },
    );
  }

  List<UserRole> _resolveAvailableRoles(User user) {
    final roles = <UserRole>[];

    if (user.rider != null) {
      roles.add(UserRole.rider);
    }
    if (user.driver != null) {
      roles.add(UserRole.driver);
    }

    return roles;
  }

  UserRole? _resolveDefaultRole(List<UserRole> roles) {
    if (roles.isEmpty) {
      return null;
    }
    if (roles.contains(UserRole.rider)) {
      return UserRole.rider;
    }
    return roles.first;
  }
}
