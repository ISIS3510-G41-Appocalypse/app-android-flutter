import 'package:equatable/equatable.dart';

import 'profile.dart';
import 'user_role.dart';

class User extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final int zoneId;
  final String authId;
  final String email;
  final Profile? rider;
  final Profile? driver;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.zoneId,
    required this.authId,
    required this.email,
    this.rider,
    this.driver,
  });

  Profile? activeProfileFor(UserRole? role) {
    switch (role) {
      case UserRole.rider:
        return rider;
      case UserRole.driver:
        return driver;
      case null:
        return null;
    }
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        zoneId,
        authId,
        email,
        rider,
        driver,
      ];
}
