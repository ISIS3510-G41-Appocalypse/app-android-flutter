import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final int id;
  final double cancellationOdds;
  final double rating;
  final int userId;

  const Profile({
    required this.id,
    required this.cancellationOdds,
    required this.rating,
    required this.userId,
  });

  @override
  List<Object?> get props => [
        id,
        cancellationOdds,
        rating,
        userId,
      ];
}
