import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final int zoneId;
  final String authId;
  final String email;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.zoneId,
    required this.authId,
    required this.email,
  });

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        zoneId,
        authId,
        email,
      ];
}