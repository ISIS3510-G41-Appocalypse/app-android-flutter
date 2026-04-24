import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/entities/user_profile.dart';

enum UserStatus {
  initial,
  loading,
  loaded,
  error,
}

class UserState extends Equatable {
  final UserStatus status;
  final User? user;
  final List<UserRole> availableRoles;
  final UserRole? activeRole;
  final UserProfile? riderProfile;
  final UserProfile? driverProfile;
  final String? errorMessage;

  const UserState({
    this.status = UserStatus.initial,
    this.user,
    this.availableRoles = const [],
    this.activeRole,
    this.riderProfile,
    this.driverProfile,
    this.errorMessage,
  });

  UserState copyWith({
    UserStatus? status,
    User? user,
    List<UserRole>? availableRoles,
    UserRole? activeRole,
    UserProfile? riderProfile,
    UserProfile? driverProfile,
    String? errorMessage,
    bool clearError = false,
    bool clearProfiles = false,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      availableRoles: availableRoles ?? this.availableRoles,
      activeRole: activeRole ?? this.activeRole,
      riderProfile: clearProfiles ? null : (riderProfile ?? this.riderProfile),
      driverProfile: clearProfiles ? null : (driverProfile ?? this.driverProfile),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  UserProfile? get activeProfile {
    switch (activeRole) {
      case UserRole.rider:
        return riderProfile;
      case UserRole.driver:
        return driverProfile;
      case null:
        return null;
    }
  }

  bool get hasMultipleRoles => availableRoles.length > 1;

  @override
  List<Object?> get props => [
        status,
        user,
        availableRoles,
        activeRole,
        riderProfile,
        driverProfile,
        errorMessage,
      ];
}
