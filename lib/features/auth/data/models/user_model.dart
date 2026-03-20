import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.zoneId,
    required super.authId,
    required super.email,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json, {
    required String email,
  }) {
    return UserModel(
      id: json['id'] as int,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      zoneId: json['zone_id'] as int? ?? 0,
      authId: json['auth_id'] as String? ?? '',
      email: email,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'zone_id': zoneId,
      'auth_id': authId,
      'email': email,
    };
  }
}