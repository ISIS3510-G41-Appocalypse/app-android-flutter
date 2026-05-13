import '../../../../core/helpers/json_parsers.dart';
import '../../domain/entities/ride_map_location.dart';

class RideMapLocationModel {
  final String id;
  final String rideId;
  final int userId;
  final String participantName;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  const RideMapLocationModel({
    required this.id,
    required this.rideId,
    required this.userId,
    required this.participantName,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  factory RideMapLocationModel.fromJson(Map<String, dynamic> json) {
    return RideMapLocationModel(
      id: json['id']?.toString() ?? '',
      rideId: json['ride_id']?.toString() ?? '',
      userId: JsonParsers.parseInt(json['user_id']),
      participantName: json['participant_name']?.toString() ?? 'Pasajero',
      latitude: JsonParsers.parseDouble(json['latitude']),
      longitude: JsonParsers.parseDouble(json['longitude']),
      updatedAt:
          DateTime.tryParse(
            (json['timestamp'] ?? json['updated_at'])?.toString() ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_id': rideId,
      'user_id': userId,
      'participant_name': participantName,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': updatedAt.toIso8601String(),
    };
  }

  RideMapLocation toEntity() {
    return RideMapLocation(
      id: id,
      rideId: rideId,
      userId: userId,
      participantName: participantName,
      latitude: latitude,
      longitude: longitude,
      updatedAt: updatedAt,
    );
  }
}
