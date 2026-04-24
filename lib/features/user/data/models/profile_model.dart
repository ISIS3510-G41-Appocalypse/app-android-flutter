import '../../../../core/helpers/json_parsers.dart';
import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.cancellationOdds,
    required super.rating,
    required super.userId,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int,
      cancellationOdds: JsonParsers.parseDouble(json['cancellation_odds']),
      rating: JsonParsers.parseDouble(json['rating']),
      userId: json['user_id'] as int,
    );
  }
}
