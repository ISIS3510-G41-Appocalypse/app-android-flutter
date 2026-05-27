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

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      zoneId: user.zoneId,
      authId: user.authId,
      email: user.email,
      rider: user.rider == null
          ? null
          : ProfileModel(
              id: user.rider!.id,
              cancellationOdds: user.rider!.cancellationOdds,
              rating: user.rider!.rating,
              userId: user.rider!.userId,
            ),
      driver: user.driver == null
          ? null
          : ProfileModel(
              id: user.driver!.id,
              cancellationOdds: user.driver!.cancellationOdds,
              rating: user.driver!.rating,
              userId: user.driver!.userId,
            ),
    );
  }

  factory UserModel.fromCacheJson(Map<String, dynamic> json) {
    final riderJson = json['rider'];
    final driverJson = json['driver'];

    return UserModel(
      id: json['id'] as int? ?? 0,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      zoneId: json['zone_id'] as int? ?? 0,
      authId: json['auth_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      rider: riderJson is Map<String, dynamic>
          ? ProfileModel.fromCacheJson(riderJson)
          : riderJson is Map
              ? ProfileModel.fromCacheJson(Map<String, dynamic>.from(riderJson))
              : null,
      driver: driverJson is Map<String, dynamic>
          ? ProfileModel.fromCacheJson(driverJson)
          : driverJson is Map
              ? ProfileModel.fromCacheJson(Map<String, dynamic>.from(driverJson))
              : null,
    );
  }

  Map<String, dynamic> toCacheJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'zone_id': zoneId,
      'auth_id': authId,
      'email': email,
      'rider': rider is ProfileModel
          ? (rider as ProfileModel).toJson()
          : rider == null
              ? null
              : {
                  'id': rider!.id,
                  'cancellation_odds': rider!.cancellationOdds,
                  'rating': rider!.rating,
                  'user_id': rider!.userId,
                },
      'driver': driver is ProfileModel
          ? (driver as ProfileModel).toJson()
          : driver == null
              ? null
              : {
                  'id': driver!.id,
                  'cancellation_odds': driver!.cancellationOdds,
                  'rating': driver!.rating,
                  'user_id': driver!.userId,
                },
    };
  }
}
