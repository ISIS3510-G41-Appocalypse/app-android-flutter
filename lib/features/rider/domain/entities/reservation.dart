import 'package:equatable/equatable.dart';

class Reservation extends Equatable {
  final int id;
  final int rideId;
  final int riderId;
  final String meetingPoint;
  final String state;
  final bool onTimeRider;
  final bool onTimeDriver;
  final String destinationPoint;

  const Reservation({
    required this.id,
    required this.rideId,
    required this.riderId,
    required this.meetingPoint,
    required this.state,
    required this.onTimeRider,
    required this.onTimeDriver,
    required this.destinationPoint,
  });

  @override
  List<Object?> get props => [
    id, rideId, riderId, meetingPoint, state, onTimeRider, onTimeDriver, destinationPoint
  ];
}
