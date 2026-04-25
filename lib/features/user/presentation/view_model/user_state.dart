import 'package:equatable/equatable.dart';

import '../../domain/entities/profile.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/entities/user.dart';

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
  final String? errorMessage;

  const UserState({
    this.status = UserStatus.initial,
    this.user,
    this.availableRoles = const [],
    this.activeRole,
    this.errorMessage,
  });

  UserState copyWith({
    UserStatus? status,
    User? user,
    List<UserRole>? availableRoles,
    UserRole? activeRole,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      availableRoles: availableRoles ?? this.availableRoles,
      activeRole: activeRole ?? this.activeRole,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  Profile? get activeProfile {
    switch (activeRole) {
      case UserRole.rider:
        return user?.rider;
      case UserRole.driver:
        return user?.driver;
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
        errorMessage,
      ];
}
