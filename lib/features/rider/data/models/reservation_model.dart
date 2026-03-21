import '../../domain/entities/reservation.dart';

class ReservationModel extends Reservation {
  const ReservationModel({
    required int id,
    required int rideId,
    required int riderId,
    required String meetingPoint,
    required String state,
    required bool onTimeRider,
    required bool onTimeDriver,
    required String destinationPoint,
  }) : super(
          id: id,
          rideId: rideId,
          riderId: riderId,
          meetingPoint: meetingPoint,
          state: state,
          onTimeRider: onTimeRider,
          onTimeDriver: onTimeDriver,
          destinationPoint: destinationPoint,
        );

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as int,
      rideId: json['ride_id'] as int,
      riderId: json['rider_id'] as int,
      meetingPoint: json['meeting_point'] as String? ?? '',
      state: json['state'] as String? ?? '',
      onTimeRider: json['on_time_rider'] as bool? ?? false,
      onTimeDriver: json['on_time_driver'] as bool? ?? false,
      destinationPoint: json['destination_point'] as String? ?? '',
    );
  }
}
