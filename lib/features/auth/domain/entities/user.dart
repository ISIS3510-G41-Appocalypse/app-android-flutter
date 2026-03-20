import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final int zoneId;
  final String authId;
  final String email;
  final int? riderId;
  final int? driverId;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.zoneId,
    required this.authId,
    required this.email,
    this.riderId,
    this.driverId,
  });

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        zoneId,
        authId,
        email,
        riderId,
        driverId,
      ];
}