import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/usecases/get_driver_profile.dart';
import '../../domain/usecases/get_rider_profile.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final GetRiderProfile getRiderProfile;
  final GetDriverProfile getDriverProfile;

  UserCubit({
    required this.getRiderProfile,
    required this.getDriverProfile,
  }) : super(const UserState());

  void clear() {
    emit(const UserState());
  }

  Future<void> initialize(User user) async {
    final availableRoles = _resolveAvailableRoles(user);
    final nextRole = availableRoles.contains(state.activeRole)
        ? state.activeRole
        : _resolveDefaultRole(availableRoles);

    emit(
      state.copyWith(
        user: user,
        availableRoles: availableRoles,
        activeRole: nextRole,
        status: UserStatus.initial,
        clearError: true,
      ),
    );

    if (nextRole != null) {
      await loadRoleProfile(nextRole);
    }
  }

  Future<void> changeRole(UserRole role) async {
    if (!state.availableRoles.contains(role)) {
      return;
    }

    emit(
      state.copyWith(
        activeRole: role,
        clearError: true,
      ),
    );

    await loadRoleProfile(role);
  }

  Future<void> loadRoleProfile(UserRole role) async {
    if (_hasProfileLoaded(role)) {
      emit(
        state.copyWith(
          status: UserStatus.loaded,
          activeRole: role,
          clearError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: UserStatus.loading,
        activeRole: role,
        clearError: true,
      ),
    );

    final user = state.user;
    if (user == null) {
      emit(
        state.copyWith(
          status: UserStatus.error,
          errorMessage: 'No hay usuario autenticado',
        ),
      );
      return;
    }

    switch (role) {
      case UserRole.rider:
        final riderId = user.riderId;
        if (riderId == null) {
          emit(
            state.copyWith(
              status: UserStatus.error,
              errorMessage: 'El usuario no tiene rol de rider',
            ),
          );
          return;
        }

        final riderResult = await getRiderProfile(riderId: riderId);
        riderResult.fold(
          (failure) {
            emit(
              state.copyWith(
                status: UserStatus.error,
                errorMessage: failure.message,
              ),
            );
          },
          (profile) {
            emit(
              state.copyWith(
                status: UserStatus.loaded,
                riderProfile: profile,
                clearError: true,
              ),
            );
          },
        );
        break;
      case UserRole.driver:
        final driverId = user.driverId;
        if (driverId == null) {
          emit(
            state.copyWith(
              status: UserStatus.error,
              errorMessage: 'El usuario no tiene rol de driver',
            ),
          );
          return;
        }

        final driverResult = await getDriverProfile(driverId: driverId);
        driverResult.fold(
          (failure) {
            emit(
              state.copyWith(
                status: UserStatus.error,
                errorMessage: failure.message,
              ),
            );
          },
          (profile) {
            emit(
              state.copyWith(
                status: UserStatus.loaded,
                driverProfile: profile,
                clearError: true,
              ),
            );
          },
        );
        break;
    }
  }

  bool _hasProfileLoaded(UserRole role) {
    switch (role) {
      case UserRole.rider:
        return state.riderProfile != null;
      case UserRole.driver:
        return state.driverProfile != null;
    }
  }

  List<UserRole> _resolveAvailableRoles(User user) {
    final roles = <UserRole>[];

    if (user.riderId != null) {
      roles.add(UserRole.rider);
    }
    if (user.driverId != null) {
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
