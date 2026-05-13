import 'package:equatable/equatable.dart';

class RideRecommendation extends Equatable {
  final int riderId;
  final int driverId;
  final double rating;

  const RideRecommendation({
    required this.riderId,
    required this.driverId,
    required this.rating,
  });

  @override
  List<Object?> get props => [
        riderId,
        driverId,
        rating,
      ];
}
