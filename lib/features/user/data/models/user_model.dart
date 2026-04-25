import '../../domain/entities/user.dart';
import 'profile_model.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.zoneId,
    required super.authId,
    required super.email,
    super.rider,
    super.driver,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json, {
    required String email,
    ProfileModel? rider,
    ProfileModel? driver,
  }) {
    return UserModel(
      id: json['id'] as int,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      zoneId: json['zone_id'] as int? ?? 0,
      authId: json['auth_id'] as String? ?? '',
      email: email,
      rider: rider,
      driver: driver,
    );
  }
}
