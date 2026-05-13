import '../../../../core/helpers/json_parsers.dart';
import '../../domain/entities/rider_ride.dart';

class RiderRideModel {
  final String reservationId;
  final String rideId;
  final int driverUserId;
  final String driverName;
  final int price;
  final String source;
  final String destination;
  final String meetingPoint;
  final String destinationPoint;
  final DateTime date;
  final String departureTime;
  final String state;
  final String carModel;

  const RiderRideModel({
    required this.reservationId,
    required this.rideId,
    required this.driverUserId,
    required this.driverName,
    required this.price,
    required this.source,
    required this.destination,
    required this.meetingPoint,
    required this.destinationPoint,
    required this.date,
    required this.departureTime,
    required this.state,
    required this.carModel,
  });

  factory RiderRideModel.fromRows({
    required Map<String, dynamic> reservationRow,
    required Map<String, dynamic> rideRow,
  }) {
    return RiderRideModel(
      reservationId: reservationRow['id'].toString(),
      rideId: reservationRow['ride_id'].toString(),
      driverUserId: JsonParsers.parseInt(rideRow['driver_user_id']),
      driverName: rideRow['driver_name'] as String? ?? '',
      price: JsonParsers.parseInt(rideRow['price']),
      source: rideRow['source'] as String? ?? '',
      destination: rideRow['destination'] as String? ?? '',
      meetingPoint: reservationRow['meeting_point'] as String? ?? '',
      destinationPoint: reservationRow['destination_point'] as String? ?? '',
      date: DateTime.parse(rideRow['date'] as String),
      departureTime: rideRow['departure_time'] as String? ?? '',
      state: reservationRow['state'] as String? ?? '',
      carModel: rideRow['car_model'] as String? ?? '',
    );
  }

  RiderRide toEntity() {
    return RiderRide(
      reservationId: reservationId,
      rideId: rideId,
      driverUserId: driverUserId,
      driverName: driverName,
      price: price,
      source: source,
      destination: destination,
      meetingPoint: meetingPoint,
      destinationPoint: destinationPoint,
      date: date,
      departureTime: departureTime,
      state: state,
      carModel: carModel,
    );
  }
}
