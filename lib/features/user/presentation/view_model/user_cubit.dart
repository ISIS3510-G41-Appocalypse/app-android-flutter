import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/auth.dart';
import '../../../../core/storage/user_role_preferences.dart';
import '../../../../core/errors/failures.dart';
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
  final UserRolePreferences userRolePreferences;

  UserCubit({
    required this.getCachedUserUseCase,
    required this.loadUserUseCase,
    required this.loadProfilesUseCase,
    required this.userRolePreferences,
  }) : super(const UserState());

  void clear() {
    emit(const UserState());
  }

  Future<void> loadUser(Auth auth) async {
    final cachedUser = getCachedUserUseCase(auth: auth);
    if (cachedUser != null) {
      final cachedRoles = _resolveAvailableRoles(cachedUser);
      final cachedNextRole = _resolveNextRole(
        userId: cachedUser.id,
        availableRoles: cachedRoles,
      );

      emit(
        state.copyWith(
          user: cachedUser,
          availableRoles: cachedRoles,
          activeRole: cachedNextRole,
          status: UserStatus.loaded,
          isShowingCachedData: true,
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
        if (cachedUser != null && failure is NetworkFailure) {
          emit(
            state.copyWith(
              status: UserStatus.loaded,
              isShowingCachedData: true,
              clearError: true,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: UserStatus.error,
            errorMessage: failure.message,
            isShowingCachedData: false,
          ),
        );
      },
      (user) async {
        final availableRoles = _resolveAvailableRoles(user);
        final nextRole = _resolveNextRole(
          userId: user.id,
          availableRoles: availableRoles,
        );

        emit(
          state.copyWith(
            user: user,
            availableRoles: availableRoles,
            activeRole: nextRole,
            status: UserStatus.loaded,
            isShowingCachedData: false,
            clearError: true,
          ),
        );

        if (nextRole != null) {
          await userRolePreferences.saveLastSelectedRole(
            userId: user.id,
            role: nextRole,
          );
        }
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
        isShowingCachedData: state.isShowingCachedData,
        clearError: true,
      ),
    );

    final userId = state.user?.id;
    if (userId != null) {
      await userRolePreferences.saveLastSelectedRole(
        userId: userId,
        role: role,
      );
    }
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
        if (failure is NetworkFailure && state.user?.activeProfileFor(state.activeRole) != null) {
          emit(
            state.copyWith(
              status: UserStatus.loaded,
              isShowingCachedData: true,
              clearError: true,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: UserStatus.error,
            errorMessage: failure.message,
            isShowingCachedData: false,
          ),
        );
      },
      (updatedUser) async {
        emit(
          state.copyWith(
            user: updatedUser,
            status: UserStatus.loaded,
            isShowingCachedData: false,
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

  UserRole? _resolveNextRole({
    required int userId,
    required List<UserRole> availableRoles,
  }) {
    final preferredRole = userRolePreferences.getLastSelectedRole(
      userId: userId,
    );
    if (preferredRole != null && availableRoles.contains(preferredRole)) {
      return preferredRole;
    }

    if (availableRoles.contains(state.activeRole)) {
      return state.activeRole;
    }

    return _resolveDefaultRole(availableRoles);
  }
}
