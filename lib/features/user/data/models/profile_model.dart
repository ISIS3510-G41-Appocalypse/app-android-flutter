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

  factory ProfileModel.fromCacheJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int? ?? 0,
      cancellationOdds: JsonParsers.parseDouble(json['cancellation_odds']),
      rating: JsonParsers.parseDouble(json['rating']),
      userId: json['user_id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cancellation_odds': cancellationOdds,
      'rating': rating,
      'user_id': userId,
    };
  }
}
