import '../../../../core/helpers/json_parsers.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.cancellationOdds,
    required super.rating,
    required super.userId,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as int,
      cancellationOdds: JsonParsers.parseDouble(json['cancellation_odds']),
      rating: JsonParsers.parseDouble(json['rating']),
      userId: json['user_id'] as int,
    );
  }
}
