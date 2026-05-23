class RideMapLocation {
  final String id;
  final String rideId;
  final int userId;
  final String participantName;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;
  final double? distanceMeters;

  const RideMapLocation({
    required this.id,
    required this.rideId,
    required this.userId,
    required this.participantName,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
    this.distanceMeters,
  });

  bool get hasValidCoordinates {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        !(latitude == 0 && longitude == 0);
  }

  RideMapLocation copyWithDistance(double? value) {
    return RideMapLocation(
      id: id,
      rideId: rideId,
      userId: userId,
      participantName: participantName,
      latitude: latitude,
      longitude: longitude,
      updatedAt: updatedAt,
      distanceMeters: value,
    );
  }
}
